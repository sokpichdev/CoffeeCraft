import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Cloud Function: Send notification when order status changes to
 * "Completed"
 *
 * Triggers: When any document in the "orders" collection is updated
 * Action: Sends FCM notification to all user devices using userId
 */
export const sendOrderCompletedNotification = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    try {
      const orderId = event.params.orderId;

      // Check if data exists
      if (!event.data) {
        logger.warn("No data associated with the event");
        return;
      }

      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      // Check if data exists
      if (!beforeData || !afterData) {
        logger.warn(`Missing data for order ${orderId}`);
        return;
      }

      // Log the status change
      const beforeStatus = beforeData.status;
      const afterStatus = afterData.status;
      logger.info(
        `Order ${orderId} status changed from ` +
        `"${beforeStatus}" to "${afterStatus}"`
      );

      // Only send notification if status changed TO "Completed"
      const wasNotCompleted = beforeData.status !== "Completed";
      const isNowCompleted = afterData.status === "Completed";

      if (wasNotCompleted && isNowCompleted) {
        logger.info(
          `Order ${orderId} completed! Sending notification...`
        );

        // Get userId from the order
        const userId = afterData.userId;

        if (!userId) {
          logger.warn(`No userId found for order ${orderId}`);
          return;
        }

        // Retrieve user document to get fcmTokens array
        const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(userId)
          .get();

        if (!userDoc.exists) {
          logger.warn(`User document not found for userId ${userId}`);
          return;
        }

        const userData = userDoc.data();
        const fcmTokensArray = userData?.fcmTokens;

        if (!fcmTokensArray || !Array.isArray(fcmTokensArray)) {
          logger.warn(`No fcmTokens array found for user ${userId}`);
          return;
        }

        // Extract tokens from the array
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const tokens: string[] = fcmTokensArray
          .map((tokenObj: any) => tokenObj.token)
          .filter((token: string) => token && token.length > 0);

        if (tokens.length === 0) {
          logger.warn(`No valid tokens found for user ${userId}`);
          return;
        }

        logger.info(`Found ${tokens.length} token(s) for user ${userId}`);

        // Build notification payload
        const payload: admin.messaging.MulticastMessage = {
          tokens: tokens,
          notification: {
            title: "Your Order is Ready!",
            body:
              `Order #${orderId.substring(0, 6)} is ready for pickup.`,
          },
          data: {
            orderId: orderId,
            status: "Completed",
            type: "order_completed",
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        // Send to all tokens
        const response =
          await admin.messaging().sendEachForMulticast(payload);
        logger.info(
          `Notification sent: ${response.successCount} successful, ` +
          `${response.failureCount} failed`
        );

        return response;
      } else {
        logger.info(
          "Status changed but not to Completed, skipping notification."
        );
        return;
      }
    } catch (error) {
      logger.error("Error sending notification:", error);
      throw error;
    }
  }
);
