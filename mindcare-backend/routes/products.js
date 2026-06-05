// routes/products.js

const express = require('express');
const db = require('../config/db');

const router = express.Router();

const VALID_CATEGORIES = [
  'Meditation',
  'Therapy',
  'Journal',
  'Course',
  'Ebook',
  'Audio',
];

function getDigitalValue(value) {
  if (value === false || value === 0 || value === '0') {
    return 0;
  }

  return 1;
}

function getActiveValue(value) {
  if (value === false || value === 0 || value === '0') {
    return 0;
  }

  return 1;
}

// GET /api/products
// Get all active products with optional search and category filter
router.get('/', async (req, res) => {
  const { search, category } = req.query;

  let query = `
    SELECT
      id,
      title,
      description,
      category,
      price,
      image_url,
      is_digital,
      is_active
    FROM products
    WHERE is_active = 1
  `;

  const params = [];

  if (category && category !== 'All') {
    query += ' AND category = ?';
    params.push(category);
  }

  if (search && search.trim() !== '') {
    query += ' AND title LIKE ?';
    params.push(`%${search.trim()}%`);
  }

  query += ' ORDER BY id DESC';

  try {
    const [rows] = await db.query(query, params);

    return res.status(200).json({
      products: rows,
    });
  } catch (err) {
    console.error('Get products error:', err);

    return res.status(500).json({
      message: 'Server error while fetching products.',
    });
  }
});

// GET /api/products/:id
// Get single active product
router.get('/:id', async (req, res) => {
  const productId = req.params.id;

  try {
    const [rows] = await db.query(
      `
      SELECT
        id,
        title,
        description,
        category,
        price,
        image_url,
        is_digital,
        is_active
      FROM products
      WHERE id = ? AND is_active = 1
      `,
      [productId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'Product not found.',
      });
    }

    return res.status(200).json({
      product: rows[0],
    });
  } catch (err) {
    console.error('Get product error:', err);

    return res.status(500).json({
      message: 'Server error while fetching product.',
    });
  }
});

// POST /api/products
// Add new product
router.post('/', async (req, res) => {
  const {
    title,
    description,
    category,
    price,
    image_url,
    is_digital,
  } = req.body;

  if (!title || title.trim() === '') {
    return res.status(400).json({
      message: 'Product title is required.',
    });
  }

  if (!description || description.trim() === '') {
    return res.status(400).json({
      message: 'Product description is required.',
    });
  }

  const productCategory = VALID_CATEGORIES.includes(category)
    ? category
    : 'Meditation';

  const productPrice = Number(price);

  if (Number.isNaN(productPrice) || productPrice < 0) {
    return res.status(400).json({
      message: 'Valid product price is required.',
    });
  }

  const digitalValue = getDigitalValue(is_digital);

  try {
    const [result] = await db.query(
      `
      INSERT INTO products
      (title, description, category, price, image_url, is_digital, is_active)
      VALUES (?, ?, ?, ?, ?, ?, 1)
      `,
      [
        title.trim(),
        description.trim(),
        productCategory,
        productPrice,
        image_url || '',
        digitalValue,
      ]
    );

    const [newProduct] = await db.query(
      `
      SELECT
        id,
        title,
        description,
        category,
        price,
        image_url,
        is_digital,
        is_active
      FROM products
      WHERE id = ?
      `,
      [result.insertId]
    );

    return res.status(201).json({
      message: 'Product added.',
      product: newProduct[0],
    });
  } catch (err) {
    console.error('Add product error:', err);

    return res.status(500).json({
      message: 'Server error while adding product.',
    });
  }
});

// PUT /api/products/:id
// Update existing product
router.put('/:id', async (req, res) => {
  const productId = req.params.id;

  const {
    title,
    description,
    category,
    price,
    image_url,
    is_digital,
    is_active,
  } = req.body;

  try {
    const [existing] = await db.query(
      'SELECT id FROM products WHERE id = ?',
      [productId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        message: 'Product not found.',
      });
    }

    const fields = [];
    const values = [];

    if (title !== undefined) {
      if (!title || title.trim() === '') {
        return res.status(400).json({
          message: 'Product title cannot be empty.',
        });
      }

      fields.push('title = ?');
      values.push(title.trim());
    }

    if (description !== undefined) {
      if (!description || description.trim() === '') {
        return res.status(400).json({
          message: 'Product description cannot be empty.',
        });
      }

      fields.push('description = ?');
      values.push(description.trim());
    }

    if (category !== undefined) {
      const productCategory = VALID_CATEGORIES.includes(category)
        ? category
        : 'Meditation';

      fields.push('category = ?');
      values.push(productCategory);
    }

    if (price !== undefined) {
      const productPrice = Number(price);

      if (Number.isNaN(productPrice) || productPrice < 0) {
        return res.status(400).json({
          message: 'Valid product price is required.',
        });
      }

      fields.push('price = ?');
      values.push(productPrice);
    }

    if (image_url !== undefined) {
      fields.push('image_url = ?');
      values.push(image_url || '');
    }

    if (is_digital !== undefined) {
      fields.push('is_digital = ?');
      values.push(getDigitalValue(is_digital));
    }

    if (is_active !== undefined) {
      fields.push('is_active = ?');
      values.push(getActiveValue(is_active));
    }

    if (fields.length === 0) {
      return res.status(400).json({
        message: 'No fields provided to update.',
      });
    }

    values.push(productId);

    await db.query(
      `
      UPDATE products
      SET ${fields.join(', ')}
      WHERE id = ?
      `,
      values
    );

    const [updatedProduct] = await db.query(
      `
      SELECT
        id,
        title,
        description,
        category,
        price,
        image_url,
        is_digital,
        is_active
      FROM products
      WHERE id = ?
      `,
      [productId]
    );

    return res.status(200).json({
      message: 'Product updated.',
      product: updatedProduct[0],
    });
  } catch (err) {
    console.error('Update product error:', err);

    return res.status(500).json({
      message: 'Server error while updating product.',
    });
  }
});

// DELETE /api/products/:id
// Soft delete product by setting is_active = 0
router.delete('/:id', async (req, res) => {
  const productId = req.params.id;

  try {
    const [existing] = await db.query(
      'SELECT id FROM products WHERE id = ?',
      [productId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        message: 'Product not found.',
      });
    }

    await db.query(
      'UPDATE products SET is_active = 0 WHERE id = ?',
      [productId]
    );

    return res.status(200).json({
      message: 'Product deleted.',
    });
  } catch (err) {
    console.error('Delete product error:', err);

    return res.status(500).json({
      message: 'Server error while deleting product.',
    });
  }
});

module.exports = router;