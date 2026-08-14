import admin from 'firebase-admin';
import fs from 'fs';
import dotenv from "dotenv";
// FCM (HTTP v1 API) requires the firebase-admin SDK, authenticated with a
// service account JSON downloaded from:
// Firebase Console -> Project Settings -> Service accounts -> Generate new private key
//
// Set FIREBASE_SERVICE_ACCOUNT_PATH in .env to the absolute path of that
// JSON file. NEVER commit the JSON file itself to git — add it to
// .gitignore (see note in .env.example).

dotenv.config({
  path: "../.env",
});

let initialized = false;

const initFirebaseAdmin = () => {
  if (initialized) return;

  const path = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!path || !fs.existsSync(path)) {
    console.warn(
      '[firebaseAdmin] FIREBASE_SERVICE_ACCOUNT_PATH not set or file not found — push notifications will be stubbed.'
    );
    return;
  }

  const serviceAccount = JSON.parse(fs.readFileSync(path, 'utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
  console.log('[firebaseAdmin] Initialized with project:', serviceAccount.project_id);
};

initFirebaseAdmin();

export const isFirebaseReady = () => initialized;
export default admin;
