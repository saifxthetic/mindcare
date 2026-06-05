// routes/orders.js

const express = require('express');
const db = require('../config/db');
const authMW = require('../middleware/auth');

const router = express.Router();

// All order routes are protected
router.use(authMW);


// GET /api/orders
// Get logged-in user's orders
router.get('/', async (req, res) => {
  try {
    const [orders] = await db.query(
      `SELECT
        id,
        user_id,
        total_amount,
        status,
        payment_method
       FROM orders
       WHERE user_id = ?
       ORDER BY id DESC`,
      [req.userId]
    );

    return res.status(200).json({
      orders,
    });
  } catch (err) {
    console.error('Get orders error:', err);

    return res.status(500).json({
      message: 'Server error while fetching orders.',
    });
  }
});


// GET /api/orders/:id
// Get single order with items and payment
router.get('/:id', async (req, res) => {
  const orderId = req.params.id;

  try {
    const [orderRows] = await db.query(
      `SELECT
        id,
        user_id,
        total_amount,
        status,
        payment_method
       FROM orders
       WHERE id = ? AND user_id = ?`,
      [orderId, req.userId]
    );

    if (orderRows.length === 0) {
      return res.status(404).json({
        message: 'Order not found.',
      });
    }

    const [items] = await db.query(
      `SELECT
        oi.id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.price,
        p.title,
        p.description,
        p.category,
        p.image_url,
        p.is_digital
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [orderId]
    );

    const [payments] = await db.query(
      `SELECT
        id,
        order_id,
        amount,
        payment_status,
        transaction_ref
       FROM payments
       WHERE order_id = ?`,
      [orderId]
    );

    return res.status(200).json({
      order: orderRows[0],
      items,
      payment: payments.length > 0 ? payments[0] : null,
    });
  } catch (err) {
    console.error('Get order detail error:', err);

    return res.status(500).json({
      message: 'Server error while fetching order details.',
    });
  }
});


// POST /api/orders
// Create order
// Body option 1:
// { "product_id": 1, "payment_method": "Demo Payment" }
//
// Body option 2:
// { "items": [{ "product_id": 1, "quantity": 1 }], "payment_method": "Demo Payment" }
router.post('/', async (req, res) => {
  const { product_id, items, payment_method } = req.body;

  let orderItems = [];

  if (product_id) {
    orderItems = [
      {
        product_id,
        quantity: 1,
      },
    ];
  } else if (Array.isArray(items) && items.length > 0) {
    orderItems = items;
  } else {
    return res.status(400).json({
      message: 'Product ID or order items are required.',
    });
  }

  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    let totalAmount = 0;
    const preparedItems = [];

    for (const item of orderItems) {
      const productId = item.product_id;
      const quantity = Number(item.quantity) > 0 ? Number(item.quantity) : 1;

      const [productRows] = await connection.query(
        `SELECT id, title, price
         FROM products
         WHERE id = ? AND is_active = 1`,
        [productId]
      );

      if (productRows.length === 0) {
        await connection.rollback();

        return res.status(404).json({
          message: `Product not found: ${productId}`,
        });
      }

      const product = productRows[0];
      const price = Number(product.price);
      const lineTotal = price * quantity;

      totalAmount += lineTotal;

      preparedItems.push({
        product_id: product.id,
        quantity,
        price,
      });
    }

    const [orderResult] = await connection.query(
      `INSERT INTO orders
       (user_id, total_amount, status, payment_method)
       VALUES (?, ?, ?, ?)`,
      [
        req.userId,
        totalAmount,
        'Paid',
        payment_method || 'Demo Payment',
      ]
    );

    const orderId = orderResult.insertId;

    for (const item of preparedItems) {
      await connection.query(
        `INSERT INTO order_items
         (order_id, product_id, quantity, price)
         VALUES (?, ?, ?, ?)`,
        [
          orderId,
          item.product_id,
          item.quantity,
          item.price,
        ]
      );
    }

    await connection.query(
      `INSERT INTO payments
       (order_id, amount, payment_status, transaction_ref)
       VALUES (?, ?, ?, ?)`,
      [
        orderId,
        totalAmount,
        'Success',
        `DEMO-${Date.now()}`,
      ]
    );

    await connection.commit();

    const [newOrder] = await db.query(
      `SELECT
        id,
        user_id,
        total_amount,
        status,
        payment_method
       FROM orders
       WHERE id = ? AND user_id = ?`,
      [orderId, req.userId]
    );

    const [newItems] = await db.query(
      `SELECT
        oi.id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.price,
        p.title,
        p.description,
        p.category,
        p.image_url,
        p.is_digital
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [orderId]
    );

    return res.status(201).json({
      message: 'Order placed successfully.',
      order: newOrder[0],
      items: newItems,
    });
  } catch (err) {
    await connection.rollback();

    console.error('Create order error:', err);

    return res.status(500).json({
      message: 'Server error while creating order.',
    });
  } finally {
    connection.release();
  }
});


// PATCH /api/orders/:id/cancel
// Cancel order if not paid
router.patch('/:id/cancel', async (req, res) => {
  const orderId = req.params.id;

  try {
    const [existing] = await db.query(
      `SELECT id, status
       FROM orders
       WHERE id = ? AND user_id = ?`,
      [orderId, req.userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        message: 'Order not found.',
      });
    }

    if (existing[0].status === 'Paid') {
      return res.status(400).json({
        message: 'Paid orders cannot be cancelled in this demo version.',
      });
    }

    await db.query(
      `UPDATE orders
       SET status = 'Cancelled'
       WHERE id = ? AND user_id = ?`,
      [orderId, req.userId]
    );

    return res.status(200).json({
      message: 'Order cancelled.',
    });
  } catch (err) {
    console.error('Cancel order error:', err);

    return res.status(500).json({
      message: 'Server error while cancelling order.',
    });
  }
});


module.exports = router;