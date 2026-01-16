const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
// const { User } = require('../models/User');

// Register
router.post('/register', async (req, res) => {
  try {
    const { email, username, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }

    // TODO: Check if user exists
    // const existingUser = await User.findByEmail(email);
    // if (existingUser) {
    //   return res.status(400).json({ error: 'User already exists' });
    // }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // TODO: Create user in database
    // const user = await User.create({
    //   email,
    //   username,
    //   passwordHash,
    // });

    // Generate JWT
    const token = jwt.sign(
      { userId: 'user_id_here', email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: {
        email,
        username,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // TODO: Find user in database
    // const user = await User.findByEmail(email);
    // if (!user) {
    //   return res.status(401).json({ error: 'Invalid credentials' });
    // }

    // TODO: Verify password
    // const isValid = await bcrypt.compare(password, user.passwordHash);
    // if (!isValid) {
    //   return res.status(401).json({ error: 'Invalid credentials' });
    // }

    // Generate JWT
    const token = jwt.sign(
      { userId: 'user_id_here', email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        email,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
