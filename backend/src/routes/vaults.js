const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const Vault = require('../models/Vault');

// Get all vaults for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const vaults = await Vault.findByUserId(userId);
    res.json({
      vaults: vaults.map(v => Vault.toSafeObject(v)),
    });
  } catch (error) {
    console.error('Get vaults error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single vault
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const vault = await Vault.findById(id);

    if (!vault) {
      return res.status(404).json({ error: 'Vault not found' });
    }

    // Check if vault belongs to user
    if (vault.user_id !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ vault: Vault.toSafeObject(vault) });
  } catch (error) {
    console.error('Get vault error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new vault
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { name, encryptedMasterKey, salt } = req.body;
    const userId = req.user.userId;

    if (!name || !encryptedMasterKey || !salt) {
      return res.status(400).json({ error: 'Name, encryptedMasterKey, and salt are required' });
    }

    const vault = await Vault.create({
      userId,
      name,
      encryptedMasterKey,
      salt,
    });

    res.status(201).json({
      message: 'Vault created successfully',
      vault: Vault.toSafeObject(vault),
    });
  } catch (error) {
    console.error('Create vault error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update vault
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, lastAccessed } = req.body;

    // Check if vault exists and belongs to user
    const vault = await Vault.findById(id);
    if (!vault) {
      return res.status(404).json({ error: 'Vault not found' });
    }
    if (vault.user_id !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await Vault.update(id, { name, lastAccessed });

    res.json({ message: 'Vault updated successfully' });
  } catch (error) {
    console.error('Update vault error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete vault
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if vault exists and belongs to user
    const vault = await Vault.findById(id);
    if (!vault) {
      return res.status(404).json({ error: 'Vault not found' });
    }
    if (vault.user_id !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await Vault.delete(id);

    res.json({ message: 'Vault deleted successfully' });
  } catch (error) {
    console.error('Delete vault error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
