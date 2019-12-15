// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.notification = functions.firestore
    .document('notifications/{documentId}')
    .onCreate((snapshot, context) => {
        const document = snapshot.data();
        const title = document.title;
        const message = document.message;
        const topic = document.language
        const documentId = snapshot.id;

        const messagingPayload = {
            notification: {
                title: title,
                body: message,
                clickAction: "FLUTTER_NOTIFICATION_CLICK"
            },
            data: {
                documentId: documentId,
            }
        };
        console.log(document)
        console.log(messagingPayload);
        admin.messaging().sendToTopic(topic, messagingPayload);
    });
