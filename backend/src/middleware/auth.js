import jwt from "jsonwebtoken";
import { prisma } from "../db.js";

export async function authenticate(req, res, next) {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Authentication token required" });
    }

    const token = header.slice(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Fetch the latest user record, including the current hospital assignment.
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId || decoded.id || decoded.sub },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        hospitalId: true,
      },
    });

    if (!user) {
      return res.status(401).json({ error: "User account not found" });
    }

    req.user = user;
    next();
  } catch (error) {
    if (
      error.name === "JsonWebTokenError" ||
      error.name === "TokenExpiredError"
    ) {
      return res.status(401).json({ error: "Invalid or expired token" });
    }

    console.error("Authentication error:", error);
    return res.status(500).json({ error: "Authentication failed" });
  }
}

export function allowRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res
        .status(403)
        .json({ error: "Forbidden: insufficient permissions" });
    }

    next();
  };
}
