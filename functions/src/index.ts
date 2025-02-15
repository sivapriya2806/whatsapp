import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

exports.sendNotification = onDocumentCreated("messages/{messageId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }

    const messageData = snapshot.data();
    const senderId = messageData.senderId;
    const recipientId = messageData.recipientId;
    const messageContent = messageData.message;

    // Get the recipient's document
    const recipientDoc = await admin.firestore()
      .collection("users")
      .doc(recipientId)
      .get();
    const recipientData = recipientDoc.data();

    // Check if the recipient has blocked the sender
    const blockedUsers = recipientData?.blockedUsers || [];
    if (blockedUsers.includes(senderId)) {
      console.log(
        `Recipient ${recipientId} has blocked sender ${senderId}. Notification not sent.`
      );
      return; // Exit the function if the sender is blocked
    }

    // Get the recipient's FCM token
    const recipientFcmToken = recipientData?.fcmToken;
    if (!recipientFcmToken) {
      console.log(
        `Recipient ${recipientId} has no FCM token. Notification not sent.`
      );
      return; // Exit the function if the recipient has no FCM token
    }

    // Prepare the notification payload
    const payload = {
      notification: {
        title: `New Message from ${senderId}`,
        body: messageContent,
      },
      data: {
        senderId: senderId,
        message: messageContent,
      },
    };

    // Send the notification
    await admin.messaging().send({
        token: recipientFcmToken,
        notification: payload.notification,
        data: payload.data,
      });
    console.log("Notification sent to ${recipientId}");
  });
