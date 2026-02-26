import {admin} from "./firebase";
import * as logger from "firebase-functions/logger";
import {NotificationDoc, FcmTokenObject} from "./types";

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
export async function getUnreadCount(userId: string): Promise<number> {
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
export async function sendAndSaveNotification(
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
          badge: unreadCount,
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
