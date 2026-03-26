import type { Express } from "express";
import { authStorage } from "./storage";
import { isAuthenticated } from "./replitAuth";

const LOCAL_DEV = process.env.LOCAL_DEV === "true";
const LOCAL_DEV_USER_ID = process.env.LOCAL_DEV_USER_ID ?? "local-admin";

// Register auth-specific routes
export function registerAuthRoutes(app: Express): void {
  app.get("/api/auth/user", isAuthenticated, async (req: any, res) => {
    try {
      if (LOCAL_DEV) {
        const user = await authStorage.getUser(LOCAL_DEV_USER_ID);
        return res.json(user ?? {
          id: LOCAL_DEV_USER_ID,
          email: "admin@ceder.local",
          firstName: "Local",
          lastName: "Admin",
          profileImageUrl: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      }
      const userId = req.user.claims.sub;
      const user = await authStorage.getUser(userId);
      res.json(user);
    } catch (error) {
      console.error("Error fetching user:", error);
      res.status(500).json({ message: "Failed to fetch user" });
    }
  });
}
