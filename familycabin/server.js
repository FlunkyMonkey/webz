const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3003;

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// Serve shared resources
app.use('/shared', express.static(path.join(__dirname, '..', 'shared')));

// Route for the home page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(PORT, () => {
  console.log(`Family Cabin website running on http://localhost:${PORT}`);
});
