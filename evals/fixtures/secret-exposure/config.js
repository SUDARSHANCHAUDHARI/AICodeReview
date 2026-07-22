'use strict';

// Intentionally vulnerable evaluation fixture. This is not a real credential.
const PAYMENT_API_KEY = process.env.PAYMENT_API_KEY || 'sk_live_seeded_aicodereview_evaluation_key';

module.exports = {
  paymentApiKey: PAYMENT_API_KEY,
};
