
import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

// Hospital Admin: list doctors who are not assigned to any hospital.
// Keep this route before /:id so "available" is not treated as a doctor ID.
router.get(
  "/available",
  authenticate,
  allowRoles("HOSPITAL_ADMIN"),
  async (req, res, next) => {
    try {
      if (!req.user.hospitalId) {
        return res.status(403).json({
          error: "Your account is not assigned to a hospital",
        });
      }

      const doctors = await prisma.user.findMany({
        where: {
          role: "DOCTOR",
          hospitalId: null,
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

// Public: list doctors, with optional search and specialization filters.
router.get("/", async (req, res, next) => {
  try {
    const { specialization, search } = req.query;

    const where = {
      role: "DOCTOR",
    };

    if (specialization) {
      where.specialization = {
        contains: String(specialization),
        mode: "insensitive",
      };
    }

    if (search) {
      where.OR = [
        { name: { contains: String(search), mode: "insensitive" } },
        { specialization: { contains: String(search), mode: "insensitive" } },
      ];
    }

    const doctors = await prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        specialization: true,
        hospitalId: true,
      },
      orderBy: { name: "asc" },
    });

    return res.json({ doctors });
  } catch (error) {
    next(error);
  }
});

// Public: get an individual doctor's details.
router.get("/:id", async (req, res, next) => {
  try {
    const doctor = await prisma.user.findFirst({
      where: {
        id: req.params.id,
        role: "DOCTOR",
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
    });

    if (!doctor) {
      return res.status(404).json({ error: "Doctor not found" });
    }

    return res.json({ doctor });
  } catch (error) {
    next(error);
  }
});

export default router;
