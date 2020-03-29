import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const addMessage = functions.https.onRequest(async (request, response) => {
    const message = request.query.text;
    // Push the new message into the Realtime Database using the Firebase Admin SDK.
    const snapshot = await admin.database().ref('/messages').push({original: message});
    // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
    response.redirect(303, snapshot.ref.toString());
    response.send("Hello from Firebase!");
});

export const makeUppercase = functions.database.ref("/messages/{pushId}/original").onCreate((snapshot, context) => {
    // Grab the current value of what was written to the Realtime Database.
    const original = snapshot.val();
    console.log('Uppercasing', context.params.pushId, original);
    const uppercase = original.toUpperCase();
    // You must return a Promise when performing asynchronous tasks inside a Functions such as
    // writing to the Firebase Realtime Database.
    // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
    return snapshot?.ref?.parent?.child('uppercase').set(uppercase);
});

export const setNextTrainBeerPerson = functions.firestore.document('/users/{id}').onUpdate((snapshot, context) => {
    // Get the user that was updated, and if 
});

/*
    TODO: Must pay for CloudScheduler on Firebase.
    Runs at 5:00pm, every Friday, every month to determine who the next
    person responsible for train beers is.
*/
export const scheduleNextTrainBeerPerson = functions.pubsub.schedule('0 0 17 ? * FRI *')
    .timeZone('America/New_York')
    .onRun((context) => {
        console.log('Runs 5:00pm, every Friday, every month');
        return null;
    }
);