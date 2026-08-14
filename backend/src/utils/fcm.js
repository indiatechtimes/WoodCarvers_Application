import admin, { isFirebaseReady } from './firebaseAdmin.js';

// Sends a push via FCM's HTTP v1 API (the legacy `fcm.googleapis.com/fcm/send`
// API this used to call was shut down by Google in June 2024). If Firebase
// Admin isn't configured (no service account JSON), this stays a safe no-op
// stub — same behavior as before, so nothing else breaks.
export const sendPushToTokens = async (tokens, notification, data = {}) => {
  if (!isFirebaseReady() || !tokens || tokens.length === 0) {
    console.log('[FCM stub]', { tokens: tokens?.length || 0, notification, data });
    return { stubbed: true, delivered: 0 };
  }

  try {
    // FCM data payload values must all be strings.
    const stringData = Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    );

    
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification,
      data: stringData,
    });

    // Clean up tokens that are no longer valid (uninstalled app, expired, etc.)
    const invalidTokens = [];
    response.responses.forEach((res, idx) => {
      if (!res.success) {
        const code = res.error?.code;
        if (
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    return {
      stubbed: false,
      delivered: response.successCount,
      failed: response.failureCount,
      invalidTokens,
    };
  } catch (err) {
    console.error('FCM send error', err);
    return { stubbed: false, error: err.message };
  }
};

// Convenience wrapper for the common case: send to a user's tokens, and
// automatically prune any tokens FCM reports as dead (uninstalled app,
// expired, etc.) so they don't keep failing on every future order update.
export const sendPushToUser = async (user, notification, data = {}) => {
  const result = await sendPushToTokens(user?.fcmTokens || [], notification, data);
  if (result.invalidTokens?.length) {
    user.fcmTokens = user.fcmTokens.filter((t) => !result.invalidTokens.includes(t));
    await user.save();
  }
  return result;
};
