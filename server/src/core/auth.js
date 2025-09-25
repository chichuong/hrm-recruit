const jwt = require('jsonwebtoken');

function generateAccessToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
}

function generateRefreshToken(user) {
  return jwt.sign(
    { id: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );
}

function authMiddleware(req, res, next) {
  const header = req.headers['authorization'];
  if (!header) return res.status(401).json({ ok: false, message: 'No token' });
  const token = header.split(' ')[1];
  if (!token) return res.status(401).json({ ok: false, message: 'Invalid token' });

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ ok: false, message: 'Token invalid/expired' });
    req.user = decoded;
    next();
  });
}

module.exports = { generateAccessToken, generateRefreshToken, authMiddleware };
