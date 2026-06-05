// routes/wishlist.js

const express = require('express');
const db = require('../config/db');
const authMW = require('../middleware/auth');

const router = express.Router();

// All wishlist routes are protected
router.use(authMW);

// GET /api/wishlist
// Get logged-in user's wishlist
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT 
        w.id AS wishlist_id,
        w.user_id,
        w.product_id,
        p.id AS id,
        p.title,
        p.description,
        p.category,
        p.price,
        p.image_url,
        p.is_digital,
        p.is_active
       FROM wishlist w
       JOIN products p ON w.product_id = p.id
       WHERE w.user_id = ? AND p.is_active = 1
       ORDER BY w.id DESC`,
      [req.userId]
    );

    return res.status(200).json({
      wishlist: rows,
    });
  } catch (err) {
    console.error('Get wishlist error:', err);
    return res.status(500).json({
      message: 'Server error while fetching wishlist.',
    });
  }
});

// POST /api/wishlist
// Add product to wishlist
router.post('/', async (req, res) => {
  const { product_id } = req.body;

  if (!product_id) {
    return res.status(400).json({
      message: 'Product ID is required.',
    });
  }

  try {
    const [productRows] = await db.query(
      `SELECT id 
       FROM products 
       WHERE id = ? AND is_active = 1`,
      [product_id]
    );

    if (productRows.length === 0) {
      return res.status(404).json({
        message: 'Product not found.',
      });
    }

    const [existing] = await db.query(
      `SELECT id 
       FROM wishlist 
       WHERE user_id = ? AND product_id = ?`,
      [req.userId, product_id]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: 'Product already exists in wishlist.',
      });
    }

    const [result] = await db.query(
      `INSERT INTO wishlist (user_id, product_id)
       VALUES (?, ?)`,
      [req.userId, product_id]
    );

    const [newItem] = await db.query(
      `SELECT 
        w.id AS wishlist_id,
        w.user_id,
        w.product_id,
        p.id AS id,
        p.title,
        p.description,
        p.category,
        p.price,
        p.image_url,
        p.is_digital,
        p.is_active
       FROM wishlist w
       JOIN products p ON w.product_id = p.id
       WHERE w.id = ? AND w.user_id = ?`,
      [result.insertId, req.userId]
    );

    return res.status(201).json({
      message: 'Product added to wishlist.',
      wishlistItem: newItem[0],
    });
  } catch (err) {
    console.error('Add wishlist error:', err);
    return res.status(500).json({
      message: 'Server error while adding wishlist item.',
    });
  }
});

// POST /api/wishlist/toggle
// Add product if not in wishlist, remove if already exists
router.post('/toggle', async (req, res) => {
  const { product_id } = req.body;

  if (!product_id) {
    return res.status(400).json({
      message: 'Product ID is required.',
    });
  }

  try {
    const [productRows] = await db.query(
      `SELECT id 
       FROM products 
       WHERE id = ? AND is_active = 1`,
      [product_id]
    );

    if (productRows.length === 0) {
      return res.status(404).json({
        message: 'Product not found.',
      });
    }

    const [existing] = await db.query(
      `SELECT id 
       FROM wishlist 
       WHERE user_id = ? AND product_id = ?`,
      [req.userId, product_id]
    );

    if (existing.length > 0) {
      await db.query(
        `DELETE FROM wishlist 
         WHERE user_id = ? AND product_id = ?`,
        [req.userId, product_id]
      );

      return res.status(200).json({
        message: 'Product removed from wishlist.',
        isWishlisted: false,
      });
    }

    await db.query(
      `INSERT INTO wishlist (user_id, product_id)
       VALUES (?, ?)`,
      [req.userId, product_id]
    );

    return res.status(201).json({
      message: 'Product added to wishlist.',
      isWishlisted: true,
    });
  } catch (err) {
    console.error('Toggle wishlist error:', err);
    return res.status(500).json({
      message: 'Server error while updating wishlist.',
    });
  }
});

// DELETE /api/wishlist/:productId
// Remove product from wishlist
router.delete('/:productId', async (req, res) => {
  const productId = req.params.productId;

  try {
    const [existing] = await db.query(
      `SELECT id 
       FROM wishlist 
       WHERE user_id = ? AND product_id = ?`,
      [req.userId, productId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        message: 'Wishlist item not found.',
      });
    }

    await db.query(
      `DELETE FROM wishlist 
       WHERE user_id = ? AND product_id = ?`,
      [req.userId, productId]
    );

    return res.status(200).json({
      message: 'Product removed from wishlist.',
    });
  } catch (err) {
    console.error('Delete wishlist error:', err);
    return res.status(500).json({
      message: 'Server error while deleting wishlist item.',
    });
  }
});

module.exports = router;