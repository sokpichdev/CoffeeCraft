import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onDocumentUpdated, onDocumentCreated}
  from "firebase-functions/v2/firestore";
import {sendAndSaveNotification} from "../lib/notifications";
import {NotificationDoc} from "../lib/types";

// ─────────────────────────────────────────────────────────
// TRIGGER: Order status changed
// ─────────────────────────────────────────────────────────
/**
 * Fires when any order document is updated.
 * Sends inbox notification + FCM push to the customer when status changes.
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
// TRIGGER: New order placed
// ─────────────────────────────────────────────────────────
/**
 * Fires when a new order document is created.
 * Sends inbox notification + FCM push to all managers.
 */
export const onOrderPlaced = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    try {
      const orderId = event.params.orderId;
      const data = event.data?.data();

      if (!data) {
        logger.warn(`onOrderPlaced: no data for order ${orderId}`);
        return;
      }

      const totalPrice: number = data.totalPrice ?? 0;
      const itemCount: number = Array.isArray(data.items) ?
        data.items.length : 0;
      const orderNumber: number = data.orderId ?? orderId;

      logger.info(
        `New order placed: #${orderNumber}, ` +
        `total: $${totalPrice.toFixed(2)}, items: ${itemCount}`
      );

      // 1. Fetch all managers
      const managersSnapshot = await admin
        .firestore()
        .collection("users")
        .where("role", "==", "manager")
        .get();

      if (managersSnapshot.empty) {
        logger.warn("No managers found to notify.");
        return;
      }

      logger.info(`📋 Found ${managersSnapshot.size} manager(s) to notify`);

      // 2. Build the notification once — same content for every manager
      const notification: NotificationDoc = {
        type: "order_status",
        title: "New Order Received ☕️",
        message:
        `A customer just placed order #${orderNumber} ` +
        `with ${itemCount} item(s). Total: $${totalPrice.toFixed(2)}`,
        isRead: false,
        createdAt: admin.firestore.Timestamp.now(),
        payload: {
          orderId: String(orderId),
          orderNumber: String(orderNumber),
          totalPrice: String(totalPrice),
          itemCount: String(itemCount),
        },
      };

      const fcmData: Record<string, string> = {
        orderId: String(orderId),
        orderNumber: String(orderNumber),
        totalPrice: String(totalPrice),
        itemCount: String(itemCount),
      };

      // 3. Notify all managers in parallel
      const notifyTasks = managersSnapshot.docs.map((managerDoc) =>
        sendAndSaveNotification(managerDoc.id, notification, fcmData)
      );

      await Promise.all(notifyTasks);

      logger.info(`✅ All managers notified for order #${orderNumber}`);
    } catch (error) {
      logger.error("Error in onOrderPlaced:", error);
      throw error;
    }
  }
);
