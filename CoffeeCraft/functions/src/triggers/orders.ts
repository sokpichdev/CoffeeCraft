import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onDocumentUpdated, onDocumentCreated}
  from "firebase-functions/v2/firestore";
import {sendAndSaveNotification,
  deleteTransientNotificationsForOrder}
  from "../lib/notifications";
import {NotificationDoc} from "../lib/types";

// ─────────────────────────────────────────────────────────
// TRIGGER: Order status changed
// ─────────────────────────────────────────────────────────
/**
 * Fires when any order document is updated.
 *
 * Notification rules by status + order type:
 *   • Ready      + pickup   → "Your order is ready! Come pick it up ☕️"
 *   • OnDelivery + delivery → "Your order is on the way 🛵"
 *   • Completed  + any      → "Order completed ✅"
 *   • Cancelled  + any      → "Your order has been cancelled"
 *
 * No notification is sent for Pending or InProgress transitions.
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

      // "delivery" | "pickup" — fall back to pickup for legacy orders
      const deliveryType: string = after.deliveryType ?? "pickup";

      logger.info(
        `Order ${orderId} [${deliveryType}]: 
        "${beforeStatus}" → "${afterStatus}"`
      );

      const userId: string = after.userId;
      if (!userId) {
        logger.warn(`No userId on order ${orderId}`);
        return;
      }

      // ── Notification copy map ────────────────────────────────────
      // Key format: "<status>" or "<status>:<deliveryType>"
      // for type-specific copy.
      // Resolved in priority order: specific key first, then generic key.
      // isTransient: true  → auto-deleted when order reaches a terminal state.
      // isTransient: false → kept in inbox permanently.
      type CopyEntry = { title: string; message: string; isTransient: boolean };

      const copyMap: Record<string, CopyEntry> = {
        // Pickup-specific — transient: only useful until the customer collects
        "Ready:pickup": {
          title: "Order ready for pickup ☕️",
          message: `Your order #${orderId} is ready! 
            Head to the branch to collect it.`,
          isTransient: true,
        },
        // Delivery-specific — transient: only useful while rider is en route
        "OnDelivery:delivery": {
          title: "Your order is on the way 🛵",
          message: `Order #${orderId} has been picked up 
            and is heading to you!`,
          isTransient: true,
        },
        // Generic — persistent: worth keeping as a record
        "Completed": {
          title: "Order completed ✅",
          message: `Order #${orderId} has been completed. Enjoy!`,
          isTransient: false,
        },
        "Cancelled": {
          title: "Order cancelled",
          message: `Your order #${orderId} has been cancelled. ` +
            "If you paid by wallet, a refund has been issued.",
          isTransient: false,
        },
      };

      // Resolve: try type-specific key first, fall back to generic
      const specificKey = `${afterStatus}:${deliveryType}`;
      const copy = copyMap[specificKey] ?? copyMap[afterStatus];

      if (!copy) {
        logger.info(
          `No notification configured for status "${afterStatus}" ` +
          `[${deliveryType}], skipping.`
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
        isTransient: copy.isTransient,
      };

      // Purge previous transient notifications
      // (Ready, OnDelivery, Payment Confirmed)
      // before saving the terminal notification so the inbox stays clean.
      if (afterStatus === "Completed" || afterStatus === "Cancelled") {
        await deleteTransientNotificationsForOrder(userId, orderId);
      }

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
      const deliveryType: string = data.deliveryType ?? "pickup";
      const itemCount: number = Array.isArray(data.items) ?
        (data.items as { quantity?: number }[])
          .reduce((sum, item) => sum + (item.quantity ?? 1), 0) : 0;
      const orderNumber: number = data.orderId ?? orderId;
      const typeLabel = deliveryType === "delivery" ? "🛵 Delivery" : "🏪 Pickup";

      logger.info(
        `New order placed: #${orderNumber} [${deliveryType}], ` +
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

      // 2. Build notification — same content for every manager
      const notification: NotificationDoc = {
        type: "order_status",
        title: "New Order Received ☕️",
        message: `🧾 Order #${orderNumber}\n` +
          `${typeLabel}\n` +
          `☕️ ${itemCount} ${itemCount === 1 ? "item" : "items"}\n` +
          `💵 $${totalPrice.toFixed(2)}`,
        isRead: false,
        createdAt: admin.firestore.Timestamp.now(),
        payload: {
          orderId: String(orderId),
          orderNumber: String(orderNumber),
          totalPrice: String(totalPrice),
          itemCount: String(itemCount),
          deliveryType: deliveryType,
        },
      };

      const fcmData: Record<string, string> = {
        orderId: String(orderId),
        orderNumber: String(orderNumber),
        totalPrice: String(totalPrice),
        itemCount: String(itemCount),
        deliveryType: deliveryType,
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
