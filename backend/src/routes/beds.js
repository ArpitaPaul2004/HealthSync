import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

router.use(authenticate);

// Book an available bed
router.post("/bookings", allowRoles("PATIENT"), async (req, res, next) => {
  try {
    const { bedId } = req.body;
    const patientId = req.user.id;

    if (!bedId || typeof bedId !== "string") {
      return res.status(400).json({ error: "A valid bedId is required" });
    }

    if (!patientId) {
      return res.status(401).json({ error: "Patient identity not found" });
    }

    const booking = await prisma.$transaction(async (tx) => {
      const bed = await tx.bed.findUnique({
        where: { id: bedId },
      });

      if (!bed) {
        throw Object.assign(new Error("Bed not found"), { status: 404 });
      }

      if (!bed.available) {
        throw Object.assign(new Error("Bed is not available"), {
          status: 409,
        });
      }

      // Update only if the bed is still available, preventing double booking.
      const bedUpdate = await tx.bed.updateMany({
        where: {
          id: bedId,
          available: true,
        },
        data: {
          available: false,
        },
      });

      if (bedUpdate.count !== 1) {
        throw Object.assign(new Error("Bed is not available"), {
          status: 409,
        });
      }

      await tx.hospital.update({
        where: { id: bed.hospitalId },
        data: {
          availableBeds: { decrement: 1 },
        },
      });

      return tx.bedBooking.create({
        data: {
          patient: {
            connect: { id: patientId },
          },
          bed: {
            connect: { id: bedId },
          },
        },
        include: {
          bed: {
            include: { hospital: true },
          },
        },
      });
    });

    return res.status(201).json({
      message: "Bed booked successfully",
      booking,
    });
  } catch (error) {
    if (error.status) {
      return res.status(error.status).json({ error: error.message });
    }

    next(error);
  }
});

// List the current patient's bookings
router.get("/bookings/mine", allowRoles("PATIENT"), async (req, res, next) => {
  try {
    const patientId = req.user.id;

    const bookings = await prisma.bedBooking.findMany({
      where: { patientId },
      include: {
        bed: {
          include: { hospital: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return res.json({ bookings });
  } catch (error) {
    next(error);
  }
});

// Cancel a booking
router.patch(
  "/bookings/:id/cancel",
  allowRoles("PATIENT", "HOSPITAL_ADMIN", "SUPER_ADMIN"),
  async (req, res, next) => {
    try {
      const booking = await prisma.bedBooking.findUnique({
        where: { id: req.params.id },
        include: { bed: true },
      });

      if (!booking) {
        return res.status(404).json({ error: "Booking not found" });
      }

      if (req.user.role === "PATIENT" && booking.patientId !== req.user.id) {
        return res.status(403).json({ error: "Not your booking" });
      }

      if (booking.status !== "BOOKED") {
        return res.status(409).json({ error: "Booking is not active" });
      }

      const updatedBooking = await prisma.$transaction(async (tx) => {
        // Only cancel an active booking.
        const updated = await tx.bedBooking.updateMany({
          where: {
            id: booking.id,
            status: "BOOKED",
          },
          data: {
            status: "CANCELLED",
          },
        });

        if (updated.count !== 1) {
          throw Object.assign(new Error("Booking is not active"), {
            status: 409,
          });
        }

        await tx.bed.update({
          where: { id: booking.bedId },
          data: { available: true },
        });

        await tx.hospital.update({
          where: { id: booking.bed.hospitalId },
          data: {
            availableBeds: { increment: 1 },
          },
        });

        return tx.bedBooking.findUnique({
          where: { id: booking.id },
          include: {
            bed: {
              include: { hospital: true },
            },
          },
        });
      });

      return res.json({
        message: "Booking cancelled successfully",
        booking: updatedBooking,
      });
    } catch (error) {
      if (error.status) {
        return res.status(error.status).json({ error: error.message });
      }

      next(error);
    }
  },
);

export default router;
