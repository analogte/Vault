const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Secure Vault API is running' });
});

// TODO: Add routes
// app.use('/api/auth', require('./routes/auth'));
// app.use('/api/vaults', require('./routes/vaults'));
// app.use('/api/files', require('./routes/files'));

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
