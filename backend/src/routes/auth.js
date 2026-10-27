
import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { prisma } from "../db.js";
import { authenticate } from "../middleware/auth.js";

const router = Router();

const publicUser = ({ passwordHash, ...user }) => user;

// Public registration: patients only.
// Doctor and hospital-admin accounts must be provisioned
// through a separate, authorized approval workflow.
router.post("/register", async (req, res) => {
  const { name, email, phone, password, role = "PATIENT" } = req.body;

  if (
    typeof name !== "string" ||
    !name.trim() ||
    typeof email !== "string" ||
    !email.trim() ||
    typeof password !== "string" ||
    password.length < 8
  ) {
    return res.status(400).json({
      error: "Valid name, email and password (8+ characters) are required",
    });
  }

  if (role !== "PATIENT") {
    return res.status(403).json({
      error: "Only patient self-registration is allowed",
    });
  }

  try {
    const user = await prisma.user.create({
      data: {
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone,
        passwordHash: await bcrypt.hash(password, 12),
        role: "PATIENT",
      },
    });

    return res.status(201).json({ user: publicUser(user) });
  } catch (error) {
    if (error.code === "P2002") {
      return res.status(409).json({ error: "Email already registered" });
    }
    throw error;
  }
});

// Login
router.post("/login", async (req, res) => {
  const { email, password, role } = req.body;

  if (
    typeof email !== "string" ||
    typeof password !== "string" ||
    !email.trim() ||
    !password
  ) {
    return res.status(400).json({
      error: "email and password are required",
    });
  }

  const user = await prisma.user.findUnique({
    where: { email: email.trim().toLowerCase() },
  });

  if (
    !user ||
    !(await bcrypt.compare(password, user.passwordHash)) ||
    (role && user.role !== role)
  ) {
    return res.status(401).json({ error: "Invalid credentials" });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({ error: "Server authentication is not configured" });
  }

  const token = jwt.sign(
    { sub: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
  );

  return res.json({ token, user: publicUser(user) });
});

// Get the current user's profile
router.get("/me", authenticate, async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.sub },
  });

  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json({ user: publicUser(user) });
});

// Update permitted profile fields
router.patch("/me", authenticate, async (req, res) => {
  const { name, phone, specialization } = req.body;

  const data = {};

  if (name !== undefined) {
    if (typeof name !== "string" || !name.trim()) {
      return res.status(400).json({ error: "Name cannot be empty" });
    }
    data.name = name.trim();
  }

  if (phone !== undefined) {
    if (typeof phone !== "string") {
      return res.status(400).json({ error: "Phone must be a string" });
    }
    data.phone = phone;
  }

  // Only doctors can update their specialization.
  if (specialization !== undefined) {
    if (req.user.role !== "DOCTOR") {
      return res.status(403).json({
        error: "Only doctors can update specialization",
      });
    }
    if (typeof specialization !== "string" || !specialization.trim()) {
      return res.status(400).json({
        error: "Specialization cannot be empty",
      });
    }
    data.specialization = specialization.trim();
  }

  const user = await prisma.user.update({
    where: { id: req.user.sub },
    data,
  });

  return res.json({ user: publicUser(user) });
});

// Change password
router.patch("/password", authenticate, async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (
    typeof currentPassword !== "string" ||
    typeof newPassword !== "string" ||
    newPassword.length < 8
  ) {
    return res.status(400).json({
      error: "A current password and new password of at least 8 characters are required",
    });
  }

  const user = await prisma.user.findUnique({
    where: { id: req.user.sub },
  });

  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  if (!(await bcrypt.compare(currentPassword, user.passwordHash))) {
    return res.status(400).json({
      error: "Current password is incorrect",
    });
  }

  await prisma.user.update({
    where: { id: user.id },
    data: {
      passwordHash: await bcrypt.hash(newPassword, 12),
    },
  });

  return res.json({ message: "Password updated" });
});

export default router;
