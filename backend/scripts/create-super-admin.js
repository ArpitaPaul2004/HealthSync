
import "dotenv/config";
import bcrypt from "bcryptjs";
import { prisma } from "../src/db.js";

async function main() {
  const name = process.env.SUPER_ADMIN_NAME;
  const email = process.env.SUPER_ADMIN_EMAIL?.trim().toLowerCase();
  const password = process.env.SUPER_ADMIN_PASSWORD;

  if (!name || !email || !password || password.length < 12) {
    throw new Error(
      "Set SUPER_ADMIN_NAME, SUPER_ADMIN_EMAIL and a password of at least 12 characters in backend/.env"
    );
  }

  const existing = await prisma.user.findUnique({
    where: { email },
  });

  if (existing) {
    if (existing.role === "SUPER_ADMIN") {
      console.log("A Super Admin with this email already exists.");
      return;
    }

    throw new Error(
      "This email already belongs to another account. Use a different email."
    );
  }

  await prisma.user.create({
    data: {
      name: name.trim(),
      email,
      passwordHash: await bcrypt.hash(password, 12),
      role: "SUPER_ADMIN",
    },
  });

  console.log(`Super Admin created: ${email}`);
}

main()
  .catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
