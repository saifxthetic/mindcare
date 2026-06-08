🧠 MindCare Wellness Marketplace

A full-stack Flutter-based mobile application that provides users with a seamless wellness marketplace experience. Users can browse wellness products, manage accounts, place orders, and maintain a personalized wishlist.

📱 Project Overview

MindCare Wellness Marketplace is designed to promote mental health and wellness by offering a digital platform where users can explore meditation courses, therapy tools, ebooks, audio sessions, and wellness products.

The application includes full authentication, product browsing, wishlist management, and order tracking.

🚀 Features
🔐 Authentication System
User Signup
Secure Login
Forgot Password
JWT-based authentication
Persistent login using SharedPreferences
🛍️ Product Features
Browse wellness products
Search products
Filter by categories
View detailed product information
❤️ Wishlist System
Add/remove products to wishlist
View saved items anytime
📦 Order System
Place orders
View order history
Track order status
👤 User Profile
View user details
Logout functionality
📱 UI/UX
Clean and modern UI
Bottom navigation bar
Responsive mobile design
🏗️ Tech Stack
Flutter (Frontend)
REST APIs
Node.js / Backend Integration
JWT Authentication & Authorization
Service Layer Architecture
Clean Code Principles
Model-View Separation
Shared Preferences (Token Storage)
🔐 Authentication Flow
User logs in with email and password
Backend validates credentials
Server generates a JWT token
Token is stored in Flutter (SharedPreferences)
Token is sent with every API request
Backend verifies token using middleware
Access granted to protected routes
