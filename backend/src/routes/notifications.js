import { Router } from "express";
import { prisma } from "../db.js";
import { authenticate } from "../middleware/auth.js";

const router = Router();

router.use(authenticate);

// Get notifications belonging to the logged-in user
router.get("/", async (req, res, next) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: "desc" },
    });

    return res.json({ notifications });
  } catch (error) {
    next(error);
  }
});

// Create a test notification for the logged-in user
// Development/testing endpoint; remove before production deployment.
router.post("/test", async (req, res, next) => {
  try {
    const notification = await prisma.notification.create({
      data: {
        userId: req.user.id,
        title: "Test Notification",
        message: "Your HealthSync notification system is working.",
      },
    });

    return res.status(201).json({ notification });
  } catch (error) {
    next(error);
  }
});

// Mark a notification as read
router.patch("/:id/read", async (req, res, next) => {
  try {
    const notification = await prisma.notification.findUnique({
      where: { id: req.params.id },
    });

    if (!notification) {
      return res.status(404).json({ error: "Notification not found" });
    }

    if (notification.userId !== req.user.id) {
      return res.status(403).json({ error: "Not your notification" });
    }

    const updatedNotification = await prisma.notification.update({
      where: { id: notification.id },
      data: { read: true },
    });

    return res.json({ notification: updatedNotification });
  } catch (error) {
    next(error);
  }
});

export default router;