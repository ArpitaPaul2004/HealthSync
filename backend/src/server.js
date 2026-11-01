
import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";

import { prisma } from "./db.js";
import authRoutes from "./routes/auth.js";
import doctorRoutes from "./routes/doctors.js";
import appointmentRoutes from "./routes/appointments.js";
import hospitalRoutes from "./routes/hospitals.js";
import bedRoutes from "./routes/beds.js";
import prescriptionRoutes from "./routes/prescriptions.js";
import notificationRoutes from "./routes/notifications.js";

const app = express();

app.use(helmet());

app.use(
  cors({
    origin:
      process.env.CLIENT_ORIGIN === "*"
        ? true
        : process.env.CLIENT_ORIGIN?.split(","),
  })
);

app.use(express.json({ limit: "1mb" }));
app.use(morgan("dev"));

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    service: "HealthSync API",
  });
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/doctors", doctorRoutes);
app.use("/api/appointments", appointmentRoutes);
app.use("/api/hospitals", hospitalRoutes);
app.use("/api/beds", bedRoutes);
app.use("/api/prescriptions", prescriptionRoutes);
app.use("/api/notifications", notificationRoutes);

// Handle unknown routes
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);

  res.status(err.status || 500).json({
    error: err.status ? err.message : "Internal server error",
  });
});

// Listen on all network interfaces so your phone can connect
const port = Number(process.env.PORT || 4000);

const server = app.listen(port, "0.0.0.0", () => {
  console.log(`HealthSync API listening on port ${port}`);
});

process.on("SIGINT", async () => {
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
});
