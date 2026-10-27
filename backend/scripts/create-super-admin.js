
import "dotenv/config";
import bcrypt from "bcryptjs";
import { prisma } from "../src/db.js";

async function main() {
  const email = process.env.SUPER_ADMIN_EMAIL?.trim().toLowerCase();
  const password = process.env.SUPER_ADMIN_PASSWORD;
  const name = process.env.SUPER_ADMIN_NAME || "HealthSync Super Admin";

  if (!email || !password || password.length < 12) {
    throw new Error(
      "Set SUPER_ADMIN_EMAIL and SUPER_ADMIN_PASSWORD (at least 12 characters) in .env"
    );
  }

  const passwordHash = await bcrypt.hash(password, 12);

  const user = await prisma.user.upsert({
    where: { email },
    update: {
      name,
      passwordHash,
      role: "SUPER_ADMIN",
      hospitalId: null,
    },
    create: {
      name,
      email,
      passwordHash,
      role: "SUPER_ADMIN",
    },
  });

  console.log("Super-admin account provisioned:", user.email);
}

main()
  .catch((error) => {
    console.error("Setup failed:", error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
