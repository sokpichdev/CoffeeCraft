import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {sendAndSaveNotification} from "../lib/notifications";
import {NotificationDoc} from "../lib/types";

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
