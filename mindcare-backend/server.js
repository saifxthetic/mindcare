// server.js

require('dotenv').config();

const express = require('express');
const cors = require('cors');

// Route imports
const authRoutes = require('./routes/auth');
const productsRoutes = require('./routes/products');
const wishlistRoutes = require('./routes/wishlist');
const ordersRoutes = require('./routes/orders');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'MindCare API is running',
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/orders', ordersRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    message: 'Route not found.',
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);

  res.status(500).json({
    message: 'Internal server error.',
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`MindCare backend running on http://localhost:${PORT}`);
});