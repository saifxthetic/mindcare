// routes/auth.js

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const router = express.Router();

function createToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
    },
    process.env.JWT_SECRET || 'fallback_secret_key',
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    }
  );
}

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({
      message: 'Name, email and password are required.',
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      message: 'Password must be at least 6 characters.',
    });
  }

  try {
    const [existingUsers] = await db.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        message: 'Email already registered.',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name.trim(), email.trim(), hashedPassword]
    );

    const [newUserRows] = await db.query(
      'SELECT id, name, email FROM users WHERE id = ?',
      [result.insertId]
    );

    const user = newUserRows[0];
    const token = createToken(user);

    return res.status(201).json({
      message: 'Account created successfully.',
      token,
      user,
    });
  } catch (err) {
    console.error('Signup error:', err);
    return res.status(500).json({
      message: 'Server error while creating account.',
    });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      message: 'Email and password are required.',
    });
  }

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email.trim()]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'Account not found.',
      });
    }

    const user = rows[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        message: 'Invalid password.',
      });
    }

    const token = createToken(user);

    return res.status(200).json({
      message: 'Login successful.',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({
      message: 'Server error while logging in.',
    });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  const { email, newPassword } = req.body;

  if (!email || !newPassword) {
    return res.status(400).json({
      message: 'Email and new password are required.',
    });
  }

  if (newPassword.length < 6) {
    return res.status(400).json({
      message: 'Password must be at least 6 characters.',
    });
  }

  try {
    const [rows] = await db.query(
      'SELECT id FROM users WHERE email = ?',
      [email.trim()]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'No account found with this email.',
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await db.query(
      'UPDATE users SET password = ? WHERE email = ?',
      [hashedPassword, email.trim()]
    );

    return res.status(200).json({
      message: 'Password reset successfully.',
    });
  } catch (err) {
    console.error('Forgot password error:', err);
    return res.status(500).json({
      message: 'Server error while resetting password.',
    });
  }
});

// GET /api/auth/profile
router.get('/profile', async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      message: 'No token provided.',
    });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'fallback_secret_key'
    );

    const [rows] = await db.query(
      'SELECT id, name, email FROM users WHERE id = ?',
      [decoded.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    return res.status(200).json({
      user: rows[0],
    });
  } catch (err) {
    return res.status(401).json({
      message: 'Invalid or expired token.',
    });
  }
});

module.exports = router;