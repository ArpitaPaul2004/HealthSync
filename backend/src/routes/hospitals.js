
import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

// Public: list approved hospitals.
router.get("/", async (req, res, next) => {
  try {
    const hospitals = await prisma.hospital.findMany({
      where: { approved: true },
      orderBy: { name: "asc" },
    });

    return res.json({ hospitals });
  } catch (error) {
    next(error);
  }
});

// Super Admin: list all hospitals, including pending approval.
router.get(
  "/managed",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const hospitals = await prisma.hospital.findMany({
        include: {
          _count: {
            select: { users: true, beds: true },
          },
        },
        orderBy: { createdAt: "desc" },
      });

      return res.json({ hospitals });
    } catch (error) {
      next(error);
    }
  }
);

// Hospital Admin: view their assigned hospital.
router.get(
  "/mine",
  authenticate,
  allowRoles("HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      if (!req.user.hospitalId) {
        return res.status(404).json({
          error: "No hospital has been assigned to your account",
        });
      }

      const hospital = await prisma.hospital.findUnique({
        where: { id: req.user.hospitalId },
        include: {
          beds: true,
          _count: {
            select: { users: true, appointments: true },
          },
        },
      });

      if (!hospital) {
        return res.status(404).json({ error: "Hospital not found" });
      }

      return res.json({ hospital });
    } catch (error) {
      next(error);
    }
  }
);

// Hospital Admin: view doctors assigned to their hospital.
router.get(
  "/mine/doctors",
  authenticate,
  allowRoles("HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      if (!req.user.hospitalId) {
        return res.status(404).json({
          error: "No hospital has been assigned to your account",
        });
      }

      const doctors = await prisma.user.findMany({
        where: {
          role: "DOCTOR",
          hospitalId: req.user.hospitalId,
        },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          specialization: true,
          hospitalId: true,
          createdAt: true,
        },
        orderBy: { name: "asc" },
      });

      return res.json({ doctors });
    } catch (error) {
      next(error);
    }
  }
);

// Hospital Admin: assign an existing, unassigned doctor to their hospital.
router.post(
  "/mine/doctors/:doctorId",
  authenticate,
  allowRoles("HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      const hospitalId = req.user.hospitalId;
      const doctorId = req.params.doctorId;

      if (!hospitalId) {
        return res.status(403).json({
          error: "Your account is not assigned to a hospital",
        });
      }

      const doctor = await prisma.user.findUnique({
        where: { id: doctorId },
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          hospitalId: true,
          specialization: true,
        },
      });

      if (!doctor || doctor.role !== "DOCTOR") {
        return res.status(404).json({ error: "Doctor not found" });
      }

      if (doctor.hospitalId === hospitalId) {
        return res.json({
          message: "Doctor is already assigned to your hospital",
          doctor,
        });
      }

      if (doctor.hospitalId !== null) {
        return res.status(409).json({
          error: "This doctor is already assigned to another hospital",
        });
      }

      // Conditional update prevents assigning the same doctor
      // to two hospitals at nearly the same time.
      const result = await prisma.user.updateMany({
        where: {
          id: doctorId,
          role: "DOCTOR",
          hospitalId: null,
        },
        data: { hospitalId },
      });

      if (result.count !== 1) {
        return res.status(409).json({
          error: "Doctor assignment changed. Refresh and try again.",
        });
      }

      const updatedDoctor = await prisma.user.findUnique({
        where: { id: doctorId },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          specialization: true,
          hospitalId: true,
        },
      });

      return res.status(200).json({
        message: "Doctor assigned to your hospital successfully",
        doctor: updatedDoctor,
      });
    } catch (error) {
      next(error);
    }
  }
);

// Hospital Admin: remove a doctor from their hospital.
// This does NOT delete the doctor's account.
router.delete(
  "/mine/doctors/:doctorId",
  authenticate,
  allowRoles("HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      const hospitalId = req.user.hospitalId;
      const doctorId = req.params.doctorId;

      if (!hospitalId) {
        return res.status(403).json({
          error: "Your account is not assigned to a hospital",
        });
      }

      const result = await prisma.user.updateMany({
        where: {
          id: doctorId,
          role: "DOCTOR",
          hospitalId,
        },
        data: { hospitalId: null },
      });

      if (result.count !== 1) {
        return res.status(404).json({
          error: "Doctor not found in your hospital",
        });
      }

      return res.json({
        message: "Doctor removed from your hospital. Their account remains active.",
      });
    } catch (error) {
      next(error);
    }
  }
);

// Public: get details of an approved hospital.
router.get("/:id", async (req, res, next) => {
  try {
    const hospital = await prisma.hospital.findFirst({
      where: {
        id: req.params.id,
        approved: true,
      },
      include: { beds: true },
    });

    if (!hospital) {
      return res.status(404).json({ error: "Hospital not found" });
    }

    return res.json({ hospital });
  } catch (error) {
    next(error);
  }
});

// Super Admin: create a hospital. It starts pending approval.
router.post(
  "/",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const { name, address, city, phone } = req.body;

      if (
        typeof name !== "string" || !name.trim() ||
        typeof address !== "string" || !address.trim() ||
        typeof city !== "string" || !city.trim()
      ) {
        return res.status(400).json({
          error: "Valid name, address and city are required",
        });
      }

      if (phone != null && typeof phone !== "string") {
        return res.status(400).json({
          error: "Phone must be a string",
        });
      }

      const hospital = await prisma.hospital.create({
        data: {
          name: name.trim(),
          address: address.trim(),
          city: city.trim(),
          phone: phone?.trim() || null,
          totalBeds: 0,
          availableBeds: 0,
          approved: false,
        },
      });

      return res.status(201).json({
        message: "Hospital created and awaiting approval",
        hospital,
      });
    } catch (error) {
      next(error);
    }
  }
);

// Super Admin: approve a hospital.
router.patch(
  "/:id/approve",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const hospital = await prisma.hospital.findUnique({
        where: { id: req.params.id },
      });

      if (!hospital) {
        return res.status(404).json({ error: "Hospital not found" });
      }

      const updated = await prisma.hospital.update({
        where: { id: hospital.id },
        data: { approved: true },
      });

      return res.json({
        message: "Hospital approved successfully",
        hospital: updated,
      });
    } catch (error) {
      next(error);
    }
  }
);

// Super Admin: assign a Hospital Admin to a hospital.
router.patch(
  "/:id/assign-admin",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const { adminId } = req.body;

      if (typeof adminId !== "string" || !adminId.trim()) {
        return res.status(400).json({ error: "adminId is required" });
      }

      const hospital = await prisma.hospital.findUnique({
        where: { id: req.params.id },
      });

      if (!hospital) {
        return res.status(404).json({ error: "Hospital not found" });
      }

      const admin = await prisma.user.findUnique({
        where: { id: adminId.trim() },
      });

      if (!admin || admin.role !== "HOSPITAL_ADMIN") {
        return res.status(404).json({
          error: "Hospital administrator not found",
        });
      }

      if (admin.hospitalId && admin.hospitalId !== hospital.id) {
        return res.status(409).json({
          error: "Administrator is already assigned to another hospital",
        });
      }

      const existingAdmin = await prisma.user.findFirst({
        where: {
          role: "HOSPITAL_ADMIN",
          hospitalId: hospital.id,
          id: { not: admin.id },
        },
      });

      if (existingAdmin) {
        return res.status(409).json({
          error: "This hospital already has an administrator",
        });
      }

      const updatedAdmin = await prisma.user.update({
        where: { id: admin.id },
        data: { hospitalId: hospital.id },
      });

      return res.json({
        message: "Hospital administrator assigned successfully",
        admin: {
          id: updatedAdmin.id,
          name: updatedAdmin.name,
          email: updatedAdmin.email,
          hospitalId: updatedAdmin.hospitalId,
        },
      });
    } catch (error) {
      next(error);
    }
  }
);

// Super Admin: list doctors assigned to a specific hospital.
router.get(
  "/:id/doctors",
  authenticate,
  allowRoles("SUPER_ADMIN", "HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      if (
        req.user.role === "HOSPITAL_ADMIN" &&
        req.user.hospitalId !== req.params.id
      ) {
        return res.status(403).json({
          error: "You can only view doctors in your assigned hospital",
        });
      }

      const hospital = await prisma.hospital.findUnique({
        where: { id: req.params.id },
      });

      if (!hospital) {
        return res.status(404).json({ error: "Hospital not found" });
      }

      const doctors = await prisma.user.findMany({
        where: {
          role: "DOCTOR",
          hospitalId: hospital.id,
        },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          specialization: true,
          hospitalId: true,
          createdAt: true,
        },
        orderBy: { name: "asc" },
      });

      return res.json({ doctors });
    } catch (error) {
      next(error);
    }
  }
);

// Public: list available beds in an approved hospital.
router.get("/:id/beds", async (req, res, next) => {
  try {
    const hospital = await prisma.hospital.findFirst({
      where: {
        id: req.params.id,
        approved: true,
      },
    });

    if (!hospital) {
      return res.status(404).json({ error: "Hospital not found" });
    }

    const beds = await prisma.bed.findMany({
      where: {
        hospitalId: hospital.id,
        available: true,
      },
      orderBy: { label: "asc" },
    });

    return res.json({ beds });
  } catch (error) {
    next(error);
  }
});

// Add beds to an assigned hospital.
router.post(
  "/:id/beds",
  authenticate,
  allowRoles("HOSPITAL_ADMIN", "SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const { beds } = req.body;

      if (
        !Array.isArray(beds) ||
        beds.length < 1 ||
        beds.length > 100 ||
        beds.some(
          (bed) =>
            !bed ||
            typeof bed.label !== "string" ||
            !bed.label.trim() ||
            (bed.ward != null && typeof bed.ward !== "string")
        )
      ) {
        return res.status(400).json({
          error: "Provide 1–100 beds with a label and optional ward",
        });
      }

      const hospital = await prisma.hospital.findUnique({
        where: { id: req.params.id },
      });

      if (!hospital) {
        return res.status(404).json({ error: "Hospital not found" });
      }

      if (
        req.user.role === "HOSPITAL_ADMIN" &&
        hospital.id !== req.user.hospitalId
      ) {
        return res.status(403).json({
          error: "You can only manage your assigned hospital",
        });
      }

      const createdBeds = await prisma.$transaction(async (tx) => {
        const result = [];

        for (const bed of beds) {
          result.push(
            await tx.bed.create({
              data: {
                hospitalId: hospital.id,
                label: bed.label.trim(),
                ward: bed.ward?.trim() || null,
              },
            })
          );
        }

        await tx.hospital.update({
          where: { id: hospital.id },
          data: {
            totalBeds: { increment: result.length },
            availableBeds: { increment: result.length },
          },
        });

        return result;
      });

      return res.status(201).json({
        message: "Beds created successfully",
        beds: createdBeds,
      });
    } catch (error) {
      if (error.code === "P2002") {
        return res.status(409).json({
          error: "A bed label already exists in this hospital",
        });
      }

      next(error);
    }
  }
);

export default router;
