
// Lightweight FCM helper using HTTP legacy API when FCM_SERVER_KEY set.
// If not configured, this is a no-op that logs to console (safe fallback).
export const sendPushToTokens = async (tokens, notification, data = {}) => {
  const key = process.env.FCM_SERVER_KEY;
  if (!key || !tokens || tokens.length === 0) {
    console.log('[FCM stub]', { tokens: tokens?.length || 0, notification, data });
    return { stubbed: true, delivered: 0 };
  }
  try {
    const results = await Promise.all(
      tokens.map(async (to) => {
        const res = await fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            Authorization: `key=${key}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ to, notification, data }),
        });
        return res.json();
      })
    );
    return { stubbed: false, delivered: results.length, results };
  } catch (err) {
    console.error('FCM send error', err);
    return { stubbed: false, error: err.message };
  }
};















// import admin from "./firebaseAdmin.js";

// export const sendPushToTokens = async (
//   tokens,
//   notification,
//   data = {}
// ) => {
//   if (!tokens || tokens.length === 0) {
//     return {
//       success: false,
//       message: "No FCM tokens found.",
//     };
//   }

//   try {
//     const message = {
//       notification,
//       data,
//       tokens,
//     };

//     const response = await admin.messaging().sendEachForMulticast(message);

//     console.log("FCM Response:", response);

//     return {
//       success: true,
//       response,
//     };
//   } catch (error) {
//     console.error("FCM Error:", error);

//     return {
//       success: false,
//       error: error.message,
//     };
//   }
// };