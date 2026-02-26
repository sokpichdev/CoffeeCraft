import * as admin from "firebase-admin";

// ─────────────────────────────────────────────────────────
// NOTIFICATION TYPE REGISTRY
// Add new notification types here as the app grows.
// ─────────────────────────────────────────────────────────
export type NotificationType =
  | "order_status"
  | "promotion"
  | "reward"
  | "announcement";

export interface NotificationDoc {
  type: NotificationType;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: admin.firestore.Timestamp;
  payload: Record<string, string>;
}

export interface FcmTokenObject {
  token: string;
  deviceId: string;
  platform: string;
  updatedAt: admin.firestore.Timestamp;
}
