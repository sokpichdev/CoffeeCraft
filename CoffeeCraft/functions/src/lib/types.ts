import * as admin from "firebase-admin";

// ─────────────────────────────────────────────────────────
// NOTIFICATION TYPE REGISTRY
// Add new notification types here as the app grows.
// ─────────────────────────────────────────────────────────
export type NotificationType =
  | "order_status"
  | "promotion"
  | "reward" // loyalty-points milestone only
  | "wallet" // topup | payment | refund transactions
  | "announcement";

export interface NotificationDoc {
  type: NotificationType;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: admin.firestore.Timestamp;
  payload: Record<string, string>;
  /**
   * When true, this notification is auto-deleted once its linked order
   * reaches a terminal state (Completed or Cancelled).
   * Transient notifications: "Ready for pickup",
     "On the way", "Payment Confirmed".
   */
  isTransient?: boolean;
}

export interface FcmTokenObject {
  token: string;
  deviceId: string;
  platform: string;
  updatedAt: admin.firestore.Timestamp;
}
