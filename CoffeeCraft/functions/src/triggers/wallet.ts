import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {sendAndSaveNotification} from "../lib/notifications";
import {NotificationDoc} from "../lib/types";

// ─────────────────────────────────────────────────────────
// TRIGGER: Wallet transaction created
// ─────────────────────────────────────────────────────────
/**
 * Fires when any wallet_transaction document is created.
 * Sends inbox notification + FCM push to the wallet owner.
 *
 * Handled types:  reward | topup | payment | refund
 * Ignored types:  anything else (logged and skipped cleanly)
 *
 * Document shape written by WalletService.swift:
 *   userId, type, amount, balanceBefore, balanceAfter,
 *   description, referenceId? (orderId for payment/refund), timestamp
 */
export const onWalletTransactionCreated = onDocumentCreated(
  "wallet_transactions/{txId}",
  async (event) => {
    try {
      const txId = event.params.txId;
      const data = event.data?.data();

      if (!data) {
        logger.warn(`onWalletTransactionCreated: no data for tx ${txId}`);
        return;
      }

      const userId: string = data.userId;
      const type: string = data.type;
      const amount: number = data.amount ?? 0;
      const balanceAfter: number = data.balanceAfter ?? 0;
      // const description: string = data.description ?? "";
      const referenceId: string | undefined = data.referenceId;

      if (!userId) {
        logger.warn(`onWalletTransactionCreated: no userId on tx ${txId}`);
        return;
      }

      logger.info(
        `Wallet tx ${txId}: type="${type}", amount=${amount}, ` +
        `userId=${userId}`
      );

      // ── Notification copy map ──────────────────────────────────────────
      // Keyed by WalletTransactionType raw value (mirrors Swift enum).
      // amount is always positive for credits, negative for debits —
      // we use Math.abs() so the copy always reads as a positive number.
      // ──────────────────────────────────────────────────────────────────
      type NotificationCopy = {
          title: string; message: string;
          isTransient: boolean};

      const orderRef = referenceId ? `Order #${referenceId}` : "your order";
      const cancelRef = referenceId ?
        `Order #${referenceId}` : "your cancelled order";
      const cc = Math.round(Math.abs(amount));

      const notificationMap: Record<string, NotificationCopy> = {
        reward: {
          title: "🎉 Loyalty Reward!",
          message: `+${cc} CC added to your wallet.`,
          isTransient: false, // milestone record — keep permanently
        },
        topup: {
          title: "✅ Wallet Topped Up",
          message: `+${cc} CC added successfully.`,
          isTransient: false, // financial record — keep permanently
        },
        payment: {
          title: "🛍️ Payment Confirmed",
          message: `-${cc} CC used for ${orderRef}.`,
          isTransient: true,
          // purged when the linked order completes or cancels
        },
        refund: {
          title: "↩️ Refund Processed",
          message: `+${cc} CC refunded for ${cancelRef}.`,
          isTransient: false, // important financial record — keep permanently
        },
      };

      const copy = notificationMap[type];
      if (!copy) {
        logger.info(
          `No notification configured for wallet type "${type}", skipping.`
        );
        return;
      }

      // ── Build and send ─────────────────────────────────────────────────
      // "wallet" type routes to WalletNotificationRow on the client.
      // "reward" is reserved exclusively for loyalty-points milestones.
      const notification: NotificationDoc = {
        type: "wallet", // WalletNotificationRow
        title: copy.title,
        message: copy.message,
        isRead: false,
        createdAt: admin.firestore.Timestamp.now(),
        isTransient: copy.isTransient,
        payload: {
          txId,
          walletTxType: type,
          amount: String(amount),
          balanceAfter: String(balanceAfter),
          ...(referenceId ? {referenceId} : {}),
        },
      };

      const fcmData: Record<string, string> = {
        txId,
        walletTxType: type,
        amount: String(amount),
        balanceAfter: String(balanceAfter),
        ...(referenceId ? {referenceId} : {}),
      };

      await sendAndSaveNotification(userId, notification, fcmData);

      logger.info(
        `✅ Wallet notification sent — type="${type}", userId=${userId}`
      );
    } catch (error) {
      logger.error("Error in onWalletTransactionCreated:", error);
      throw error;
    }
  }
);
