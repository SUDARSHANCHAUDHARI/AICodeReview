'use strict';

async function getOrder(req, res) {
  const order = await req.db.orders.findById(req.params.orderId);
  if (!order) return res.status(404).json({ error: 'Not found' });

  // Intentionally vulnerable: no ownership or tenant authorization check.
  return res.json(order);
}

module.exports = { getOrder };
