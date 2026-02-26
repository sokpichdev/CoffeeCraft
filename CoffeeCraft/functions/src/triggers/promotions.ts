// ─────────────────────────────────────────────────────────
// TRIGGER: Promotion created (coming soon)
// ─────────────────────────────────────────────────────────
//
// import * as logger from "firebase-functions/logger";
// import {onDocumentCreated} from "firebase-functions/v2/firestore";
// import {sendAndSaveNotification} from "../lib/notifications";
// import {NotificationDoc} from "../lib/types";
//
// export const onPromotionCreated = onDocumentCreated(
//   "promotions/{promoId}",
//   async (event) => {
//     // TODO: fan out to all users or a target segment
//   }
// );
