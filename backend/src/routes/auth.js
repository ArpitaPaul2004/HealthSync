
import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { prisma } from "../db.js";
import { authenticate, allowRoles } from "../middleware/auth.js";

const router = Router();

const publicUser = ({ passwordHash, ...user }) => user;

function normalizePhone(value) {
  if (typeof value !== "string") return "";
  const phone = value.trim().replace(/[\s()-]/g, "");
  if (/^\d{10}$/.test(phone)) return `+91${phone}`;
  if (/^91\d{10}$/.test(phone)) return `+${phone}`;
  return phone;
}

// Public registration: patients only.
router.post("/register", async (req, res) => {
  const { name, email, phone, password, role = "PATIENT" } = req.body;

  if (
    typeof name !== "string" || !name.trim() ||
    typeof email !== "string" || !email.trim() ||
    typeof password !== "string" || password.length < 8
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
        phone: typeof phone === "string" ? normalizePhone(phone) : null,
        passwordHash: await bcrypt.hash(password, 12),
        role: "PATIENT",
      },
    });

    return res.status(201).json({ user: publicUser(user) });
  } catch (error) {
    if (error.code === "P2002") {
      return res.status(409).json({
        error: "Email or phone already registered",
      });
    }

    console.error("Patient registration failed:", error);
    return res.status(500).json({
      error: "Could not register patient",
    });
  }
});

// Login with email OR phone and password.
router.post("/login", async (req, res) => {
  const { email, password, role } = req.body;

  if (
    typeof email !== "string" ||
    typeof password !== "string" ||
    !email.trim() ||
    !password
  ) {
    return res.status(400).json({
      error: "Email/phone and password are required",
    });
  }

  const identifier = email.trim();
  const normalizedPhone = normalizePhone(identifier);
  const looksLikePhone = /^\+?\d{10,15}$/.test(
    identifier.replace(/[\s()-]/g, "")
  );

  const user = looksLikePhone
    ? await prisma.user.findFirst({
        where: { phone: normalizedPhone },
      })
    : await prisma.user.findUnique({
        where: { email: identifier.toLowerCase() },
      });

  if (
    !user ||
    !(await bcrypt.compare(password, user.passwordHash)) ||
    (role && user.role !== role)
  ) {
    return res.status(401).json({
      error: "Invalid email/mobile number or password",
    });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({
      error: "Server authentication is not configured",
    });
  }

  const token = jwt.sign(
    { sub: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
  );

  return res.json({
    token,
    user: publicUser(user),
  });
});

// Get authenticated user's profile.
router.get("/me", authenticate, async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.sub },
  });

  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json({ user: publicUser(user) });
});

// Update authenticated user's profile.
router.patch("/me", authenticate, async (req, res) => {
  const { name, phone, specialization } = req.body;
  const data = {};

  if (name !== undefined) {
    if (typeof name !== "string" || !name.trim()) {
      return res.status(400).json({
        error: "Name cannot be empty",
      });
    }
    data.name = name.trim();
  }

  if (phone !== undefined) {
    if (typeof phone !== "string") {
      return res.status(400).json({
        error: "Phone must be a string",
      });
    }
    data.phone = normalizePhone(phone);
  }

  if (specialization !== undefined) {
    if (req.user.role !== "DOCTOR") {
      return res.status(403).json({
        error: "Only doctors can update specialization",
      });
    }

    if (
      typeof specialization !== "string" ||
      !specialization.trim()
    ) {
      return res.status(400).json({
        error: "Specialization cannot be empty",
      });
    }

    data.specialization = specialization.trim();
  }

  try {
    const user = await prisma.user.update({
      where: { id: req.user.sub },
      data,
    });

    return res.json({ user: publicUser(user) });
  } catch (error) {
    if (error.code === "P2002") {
      return res.status(409).json({
        error: "Phone number already registered",
      });
    }

    console.error("Profile update failed:", error);
    return res.status(500).json({
      error: "Could not update profile",
    });
  }
});

// Delete only the authenticated user's account.
router.delete("/me", authenticate, async (req, res) => {
  try {
    await prisma.user.delete({
      where: { id: req.user.sub },
    });

    return res.json({ message: "Account deleted" });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "User not found" });
    }

    if (error.code === "P2003" || error.code === "P2014") {
      return res.status(409).json({
        error: "This account has linked records and cannot be deleted yet.",
      });
    }

    console.error("Account deletion failed:", error);
    return res.status(500).json({
      error: "Could not delete account",
    });
  }
});

// Change authenticated user's password.
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

// Super Admin provisions doctor accounts.
router.post(
  "/admin/doctors",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res) => {
    const { name, email, phone, password, specialization } = req.body;

    if (
      typeof name !== "string" || !name.trim() ||
      typeof email !== "string" || !email.trim() ||
      typeof password !== "string" || password.length < 8
    ) {
      return res.status(400).json({
        error: "Name, email and password (8+ characters) are required",
      });
    }

    try {
      const doctor = await prisma.user.create({
        data: {
          name: name.trim(),
          email: email.trim().toLowerCase(),
          phone:
            typeof phone === "string" && phone.trim()
              ? normalizePhone(phone)
              : null,
          passwordHash: await bcrypt.hash(password, 12),
          role: "DOCTOR",
          specialization:
            typeof specialization === "string" && specialization.trim()
              ? specialization.trim()
              : "General Physician",
        },
      });

      return res.status(201).json({
        message: "Doctor account provisioned successfully",
        user: publicUser(doctor),
      });
    } catch (error) {
      if (error.code === "P2002") {
        return res.status(409).json({
          error: "This email or phone number is already registered",
        });
      }

      console.error("Doctor provisioning failed:", error);
      return res.status(500).json({
        error: "Could not create doctor account",
      });
    }
  }
);

// Super Admin creates a Hospital Admin and assigns them to a hospital.
router.post(
  "/admin/hospital-admins",
  authenticate,
  allowRoles("SUPER_ADMIN"),
  async (req, res) => {
    const { name, email, phone, password, hospitalId } = req.body;

    if (
      typeof name !== "string" || !name.trim() ||
      typeof email !== "string" || !email.trim() ||
      typeof password !== "string" || password.length < 8 ||
      typeof hospitalId !== "string" || !hospitalId.trim()
    ) {
      return res.status(400).json({
        error: "Name, email, password (8+ characters), and hospitalId are required",
      });
    }

    try {
      const hospital = await prisma.hospital.findUnique({
        where: { id: hospitalId.trim() },
      });

      if (!hospital) {
        return res.status(404).json({
          error: "Hospital not found",
        });
      }

      const existingAdmin = await prisma.user.findFirst({
        where: {
          role: "HOSPITAL_ADMIN",
          hospitalId: hospital.id,
        },
      });

      if (existingAdmin) {
        return res.status(409).json({
          error: "This hospital already has an assigned administrator",
        });
      }

      const admin = await prisma.user.create({
        data: {
          name: name.trim(),
          email: email.trim().toLowerCase(),
          phone:
            typeof phone === "string" && phone.trim()
              ? normalizePhone(phone)
              : null,
          passwordHash: await bcrypt.hash(password, 12),
          role: "HOSPITAL_ADMIN",
          hospitalId: hospital.id,
        },
      });

      return res.status(201).json({
        message: "Hospital Admin account created and assigned successfully",
        admin: publicUser(admin),
        hospital: {
          id: hospital.id,
          name: hospital.name,
          city: hospital.city,
        },
      });
    } catch (error) {
      if (error.code === "P2002") {
        return res.status(409).json({
          error: "This email or phone number is already registered",
        });
      }

      console.error("Hospital Admin provisioning failed:", error);
      return res.status(500).json({
        error: "Could not create Hospital Admin account",
      });
    }
  }
);

export default router;
