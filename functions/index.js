const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Callable function to request admin promotion
// Expects data: { uid: string, code: string }
// Secured by an ADMIN_SECRET stored in environment config (functions:config:set admin.secret="...")
exports.requestAdmin = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  const code = data.code;

  if (!uid || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing uid or code');
  }

  // Only authenticated callers may request (optional — adjust as needed)
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Request must be authenticated');
  }

  const ADMIN_SECRET = functions.config().admin?.secret || process.env.ADMIN_SECRET;
  if (!ADMIN_SECRET) {
    throw new functions.https.HttpsError('failed-precondition', 'Admin secret not configured on functions');
  }

  if (code !== ADMIN_SECRET) {
    throw new functions.https.HttpsError('permission-denied', 'Invalid admin code');
  }

  // Promote the user by updating Firestore and setting a custom claim.
  const firestore = admin.firestore();
  const userRef = firestore.collection('users').doc(uid);

  await userRef.set({ role: 'admin', approved: true }, { merge: true });

  // Set custom claim for admin
  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
  } catch (err) {
    // Log but continue — client rules check role field first
    console.error('Failed setting custom claims', err);
  }

  return { success: true };
});
