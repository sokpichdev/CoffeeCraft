import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Cloud Function: Send notification when order status changes to
 * "Completed"
 *
 * Triggers: When any document in the "orders" collection is updated
 * Action: Sends FCM notification to the device that placed the order
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

        // Get device token from the order
        const deviceToken = afterData.deviceToken;

        if (!deviceToken) {
          logger.warn(
            `No device token found for order ${orderId}`
          );
          return;
        }

        // Build notification payload
        const payload: admin.messaging.Message = {
          token: deviceToken,
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

        // Send the notification
        const response = await admin.messaging().send(payload);
        logger.info("Notification sent successfully:", response);

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

/**
 * Optional: Send notification for other status changes
 * Uncomment if you want to notify users on all status changes
 */
/*
export const sendOrderStatusNotification = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    try {
      const orderId = event.params.orderId;

      if (!event.data) {
        logger.warn("No data associated with the event");
        return;
      }

      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) {
        logger.warn(`Missing data for order ${orderId}`);
        return;
      }

      // Only send if status actually changed
      if (beforeData.status === afterData.status) {
        return;
      }

      const deviceToken = afterData.deviceToken;
      if (!deviceToken) {
        logger.warn(`No device token for order ${orderId}`);
        return;
      }

      // Different messages for different statuses
      let title = "Order Update";
      let body = "";

      switch (afterData.status) {
      case "InProgress":
        title = "Order In Progress";
        body = `Your order #${orderId.substring(0, 6)} is being prepared.`;
        break;
      case "Ready":
        title = "Order Ready!";
        body = `Your order #${orderId.substring(0, 6)} is ready for pickup.`;
        break;
      case "Completed":
        title = "Order Complete";
        body = `Thank you! Order #${orderId.substring(0, 6)} is completed.`;
        break;
      default:
        return;
      }

      const payload: admin.messaging.Message = {
        token: deviceToken,
        notification: {title, body},
        data: {
          orderId: orderId,
          status: afterData.status,
          type: "order_status_update",
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

      const response = await admin.messaging().send(payload);
      logger.info(`Notification sent for ${afterData.status}:`, response);

      return response;
    } catch (error) {
      logger.error("Error sending notification:", error);
      throw error;
    }
  }
);
*/
