import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

router.use(authenticate);

// Get prescriptions belonging to the logged-in patient or created by the doctor
router.get("/", allowRoles("PATIENT", "DOCTOR"), async (req, res, next) => {
  try {
    const where =
      req.user.role === "DOCTOR"
        ? { doctorId: req.user.id }
        : { patientId: req.user.id };

    const prescriptions = await prisma.prescription.findMany({
      where,
      include: {
        doctor: {
          select: {
            id: true,
            name: true,
            specialization: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return res.json({ prescriptions });
  } catch (error) {
    next(error);
  }
});

// Create a prescription — doctors only
router.post("/", allowRoles("DOCTOR"), async (req, res, next) => {
  try {
    const { patientName, patientId, diagnosis, medicines, instructions } =
      req.body;

    if (
      typeof patientName !== "string" ||
      !patientName.trim() ||
      medicines == null ||
      (typeof medicines !== "string" && !Array.isArray(medicines))
    ) {
      return res.status(400).json({
        error: "patientName and medicines are required",
      });
    }

    if (patientId) {
      const patient = await prisma.user.findFirst({
        where: {
          id: patientId,
          role: "PATIENT",
        },
      });

      if (!patient) {
        return res.status(404).json({ error: "Patient not found" });
      }
    }

    const prescription = await prisma.prescription.create({
      data: {
        patientName: patientName.trim(),
        patientId: patientId || null,
        diagnosis: diagnosis || null,
        medicines:
          typeof medicines === "string"
            ? medicines
            : JSON.stringify(medicines),
        instructions: instructions || null,
        doctorId: req.user.id,
      },
    });

    return res.status(201).json({ prescription });
  } catch (error) {
    next(error);
  }
});

export default router;