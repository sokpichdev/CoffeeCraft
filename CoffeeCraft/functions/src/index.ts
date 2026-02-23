import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";

admin.initializeApp();

// ─────────────────────────────────────────────────────────
// NOTIFICATION TYPE REGISTRY
// Add new notification types here as the app grows.
// ─────────────────────────────────────────────────────────
type NotificationType =
  | "order_status"
  | "promotion"
  | "reward"
  | "announcement";

interface NotificationDoc {
  type: NotificationType;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: admin.firestore.Timestamp;
  payload: Record<string, string>;
}

interface FcmTokenObject {
  token: string;
  deviceId: string;
  platform: string;
  updatedAt: admin.firestore.Timestamp;
}

// ─────────────────────────────────────────────────────────
// HELPER: get true unread count from Firestore
// Always query after saving so the new notification is included.
// ─────────────────────────────────────────────────────────
/**
 * Returns the number of unread notifications for a user.
 *
 * @param {string} userId - The Firestore user document ID.
 * @return {Promise<number>} The unread notification count.
 */
async function getUnreadCount(userId: string): Promise<number> {
  const snapshot = await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .where("isRead", "==", false)
    .get();

  return snapshot.size;
}

// ─────────────────────────────────────────────────────────
// HELPER: persist notification to Firestore + send FCM
// Centralise here so every future trigger just calls this.
// ─────────────────────────────────────────────────────────
/**
 * Saves a notification document to the user's inbox in Firestore
 * and sends an FCM push to all of the user's devices.
 *
 * @param {string} userId - The Firestore user document ID.
 * @param {NotificationDoc} notification - The notification to save.
 * @param {Record<string, string>} fcmData - Extra data for FCM payload.
 * @return {Promise<void>}
 */
async function sendAndSaveNotification(
  userId: string,
  notification: NotificationDoc,
  fcmData: Record<string, string>
): Promise<void> {
  // 1. Save to Firestore inbox first so it's included in the unread count
  await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .add(notification);

  logger.info(`📥 Notification saved to inbox for user ${userId}`);

  // 2. Query real unread count — now includes the notification we just saved
  const unreadCount = await getUnreadCount(userId);
  logger.info(`🔴 Unread count for user ${userId}: ${unreadCount}`);

  // 3. Fetch FCM tokens from the array field on the user document
  const userDoc = await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .get();

  if (!userDoc.exists) {
    logger.warn(`User document not found for userId ${userId}`);
    return;
  }

  const fcmTokensArray = userDoc.data()?.fcmTokens as
    | FcmTokenObject[]
    | undefined;

  if (!fcmTokensArray || !Array.isArray(fcmTokensArray)) {
    logger.warn(`No fcmTokens array found for user ${userId}`);
    return;
  }

  const tokens: string[] = fcmTokensArray
    .map((obj: FcmTokenObject) => obj.token)
    .filter((t: string) => t && t.length > 0);

  if (tokens.length === 0) {
    logger.warn(`No valid tokens for user ${userId}`);
    return;
  }

  // 4. Send FCM push with real unread count as the badge
  const payload: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: notification.title,
      body: notification.message,
    },
    data: {
      ...fcmData,
      type: notification.type,
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: unreadCount, // ← real count, not hardcoded 1
        },
      },
    },
  };

  const response = await admin.messaging().sendEachForMulticast(payload);
  logger.info(
    `📲 FCM sent: ${response.successCount} success, ` +
    `${response.failureCount} failed`
  );
}

// ─────────────────────────────────────────────────────────
// TRIGGER: Order status changed
// ─────────────────────────────────────────────────────────
/**
 * Fires when any order document is updated.
 * Sends inbox notification + FCM push when status changes.
 */
export const onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    try {
      const orderId = event.params.orderId;
      if (!event.data) return;

      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!before || !after) return;

      const beforeStatus: string = before.status;
      const afterStatus: string = after.status;

      if (beforeStatus === afterStatus) return;

      logger.info(
        `Order ${orderId}: "${beforeStatus}" → "${afterStatus}"`
      );

      const userId: string = after.userId;
      if (!userId) {
        logger.warn(`No userId on order ${orderId}`);
        return;
      }

      // Map status → notification copy.
      // Add new statuses here without touching anything else.
      const statusMap: Record<
        string,
        {title: string; message: string}
      > = {
        Completed: {
          title: "Order completed ✅",
          message: `Order #${orderId} has been completed. Enjoy!`,
        },
      };

      const copy = statusMap[afterStatus];
      if (!copy) {
        logger.info(
          "No notification configured for status " +
          `"${afterStatus}", skipping.`
        );
        return;
      }

      const notification: NotificationDoc = {
        type: "order_status",
        title: copy.title,
        message: copy.message,
        isRead: false,
        createdAt: admin.firestore.Timestamp.now(),
        payload: {orderId, status: afterStatus},
      };

      await sendAndSaveNotification(userId, notification, {
        orderId,
        status: afterStatus,
      });
    } catch (error) {
      logger.error("Error in onOrderStatusChanged:", error);
      throw error;
    }
  }
);

// ─────────────────────────────────────────────────────────
// FUTURE TRIGGERS
//
// export const onPromotionCreated = onDocumentCreated(
//   "promotions/{promoId}",
//   async (event) => {
//     // build NotificationDoc with type: "promotion"
//     // call sendAndSaveNotification for each user
//   }
// );
// ─────────────────────────────────────────────────────────

