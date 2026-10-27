
import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

// List approved hospitals
router.get("/", async (req, res) => {
  const hospitals = await prisma.hospital.findMany({
    where: { approved: true },
    orderBy: { name: "asc" },
  });

  res.json({ hospitals });
});

// Get approved hospital details
router.get("/:id", async (req, res) => {
  const hospital = await prisma.hospital.findFirst({
    where: { id: req.params.id, approved: true },
    include: { beds: true },
  });

  if (!hospital) {
    return res.status(404).json({ error: "Hospital not found" });
  }

  res.json({ hospital });
});

// Create hospital. New hospitals require approval.
router.post(
  "/",
  authenticate,
  allowRoles("HOSPITAL_ADMIN", "SUPER_ADMIN"),
  async (req, res) => {
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

    const hospital = await prisma.hospital.create({
      data: {
        name: name.trim(),
        address: address.trim(),
        city: city.trim(),
        phone,
        totalBeds: 0,
        availableBeds: 0,
        approved: false,
      },
    });

    res.status(201).json({ hospital });
  }
);

// Approve a hospital
router.patch(
  "/:id/approve",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res) => {
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

    res.json({ hospital: updated });
  }
);

// Assign a hospital administrator
router.patch(
  "/:id/assign-admin",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res) => {
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
      where: { id: adminId },
    });

    if (!admin || admin.role !== "HOSPITAL_ADMIN") {
      return res.status(404).json({
        error: "Hospital administrator not found",
      });
    }

    // An administrator should manage only one hospital.
    const existingAssignment = await prisma.hospital.findFirst({
      where: {
        id: { not: hospital.id },
        // hospitalId on User records is used for assignment;
        // the ownership check below prevents conflicting assignments.
      },
    });

    const assignedElsewhere = await prisma.user.findFirst({
      where: {
        id: admin.id,
        hospitalId: { not: null },
        NOT: { hospitalId: hospital.id },
      },
    });

    if (assignedElsewhere) {
      return res.status(409).json({
        error: "Administrator is already assigned to another hospital",
      });
    }

    const updatedAdmin = await prisma.user.update({
      where: { id: admin.id },
      data: { hospitalId: hospital.id },
    });

    res.json({
      message: "Hospital administrator assigned successfully",
      admin: {
        id: updatedAdmin.id,
        name: updatedAdmin.name,
        email: updatedAdmin.email,
        hospitalId: updatedAdmin.hospitalId,
      },
    });
  }
);

// List available beds in an approved hospital
router.get("/:id/beds", async (req, res) => {
  const hospital = await prisma.hospital.findFirst({
    where: { id: req.params.id, approved: true },
  });

  if (!hospital) {
    return res.status(404).json({ error: "Hospital not found" });
  }

  const beds = await prisma.bed.findMany({
    where: { hospitalId: hospital.id, available: true },
    orderBy: { label: "asc" },
  });

  res.json({ beds });
});

// Add beds to an assigned hospital
router.post(
  "/:id/beds",
  authenticate,
  allowRoles("HOSPITAL_ADMIN", "SUPER_ADMIN"),
  async (req, res) => {
    const { beds } = req.body;

    if (
      !Array.isArray(beds) ||
      beds.length < 1 ||
      beds.length > 100 ||
      beds.some(
        (bed) =>
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

    try {
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

      res.status(201).json({
        message: "Beds created successfully",
        beds: createdBeds,
      });
    } catch (error) {
      if (error.code === "P2002") {
        return res.status(409).json({
          error: "A bed label already exists in this hospital",
        });
      }
      throw error;
    }
  }
);

export default router;
