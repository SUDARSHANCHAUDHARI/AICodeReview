'use strict';

async function getOrder(req, res) {
  const order = await req.db.orders.findById(req.params.orderId);
  if (!order) return res.status(404).json({ error: 'Not found' });
  if (order.tenantId !== req.user.tenantId) return res.status(404).json({ error: 'Not found' });

  return res.json({
    id: order.id,
    status: order.status,
    total: order.total,
  });
}

module.exports = { getOrder };
