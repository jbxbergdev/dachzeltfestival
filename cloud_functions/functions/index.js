// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.notification = functions
    .region('europe-west1')
    .firestore
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

exports.notificationQueue = functions
    .region('europe-west1')
    .pubsub
    .schedule('every 1 minutes')
    .onRun((context) => {
        const now = admin.firestore.Timestamp.now();
        const query = admin.firestore().collection('notification_queue')
            .where('timestamp', '<=', now);
        query.get().then((querySnapshot) => {
            console.log('querySnapshot size: ' + querySnapshot.size);
            if (!querySnapshot.empty) {
                querySnapshot.forEach((snapshot) => {
                    admin.firestore().collection('notifications').add(snapshot.data());
                    snapshot.ref.delete();
                });
            }
            return null;
        }).catch((error) => {});
    });
