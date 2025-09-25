const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { generateAccessToken, generateRefreshToken, authMiddleware } = require('../core/auth');

const router = express.Router();

// Register (chỉ demo, thực tế nên hạn chế HR tự đăng ký)
router.post('/register', async (req, res) => {
  const prisma = req.app.locals.prisma;
  const { email, password, name, role } = req.body;
  const hashed = await bcrypt.hash(password, 10);

  try {
    const user = await prisma.user.create({
      data: { email, password: hashed, name, role: role || 'HR' }
    });
    res.json({ ok: true, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
  } catch (e) {
    res.status(400).json({ ok: false, message: 'Email already exists' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const prisma = req.app.locals.prisma;
  const { email, password } = req.body;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return res.status(401).json({ ok: false, message: 'Invalid credentials' });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(401).json({ ok: false, message: 'Invalid credentials' });

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  res.json({
    ok: true,
    accessToken,
    refreshToken,
    user: { id: user.id, email: user.email, name: user.name, role: user.role }
  });
});

// Refresh token
router.post('/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(401).json({ ok: false, message: 'No refresh token' });

  jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ ok: false, message: 'Invalid refresh token' });
    const accessToken = jwt.sign(
      { id: decoded.id },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );
    res.json({ ok: true, accessToken });
  });
});

// Me
router.get('/me', authMiddleware, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const user = await prisma.user.findUnique({ where: { id: req.user.id } });
  res.json({ ok: true, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
});

module.exports = router;
