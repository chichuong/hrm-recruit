const express = require('express');
const { authMiddleware } = require('../core/auth');
const router = express.Router();

// (Tùy chọn) chỉ HR/ADMIN mới được viết
function requireHR(req, res, next) {
  if (req.user?.role === 'HR' || req.user?.role === 'ADMIN') return next();
  return res.status(403).json({ ok:false, message:'Forbidden' });
}

// CREATE
router.post('/', authMiddleware, requireHR, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const { title, description, level, type, salaryFrom, salaryTo } = req.body;
  if (!title || !description) return res.status(400).json({ ok:false, message:'title & description required' });

  const job = await prisma.job.create({
    data: { title, description, level, type, salaryFrom, salaryTo }
  });
  res.json({ ok:true, data:job });
});

// LIST + search + paginate ?page=1&limit=10&search=dev&status=published
router.get('/', authMiddleware, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const page = Math.max(parseInt(req.query.page||'1'),1);
  const limit = Math.min(Math.max(parseInt(req.query.limit||'10'),1),50);
  const q = (req.query.search||'').trim();
  const status = (req.query.status||'').trim();

  const where = {
    AND: [
      q ? { OR:[{ title:{ contains:q } }, { description:{ contains:q } }] } : {},
      status ? { status } : {},
    ]
  };

  const [total, items] = await Promise.all([
    prisma.job.count({ where }),
    prisma.job.findMany({
      where,
      orderBy: { createdAt:'desc' },
      skip: (page-1)*limit,
      take: limit
    })
  ]);

  res.json({ ok:true, data:items, meta:{ page, limit, total } });
});

// DETAIL
router.get('/:id', authMiddleware, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const id = Number(req.params.id);
  const job = await prisma.job.findUnique({ where:{ id } });
  if (!job) return res.status(404).json({ ok:false, message:'Not found' });
  res.json({ ok:true, data:job });
});

// UPDATE
router.put('/:id', authMiddleware, requireHR, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const id = Number(req.params.id);
  const { title, description, level, type, salaryFrom, salaryTo } = req.body;
  const job = await prisma.job.update({
    where: { id },
    data: { title, description, level, type, salaryFrom, salaryTo }
  });
  res.json({ ok:true, data:job });
});

// PUBLISH
router.patch('/:id/publish', authMiddleware, requireHR, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const id = Number(req.params.id);
  const job = await prisma.job.update({
    where:{ id },
    data:{ status:'published', publishedAt: new Date() }
  });
  res.json({ ok:true, data:job });
});

// CLOSE
router.patch('/:id/close', authMiddleware, requireHR, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const id = Number(req.params.id);
  const job = await prisma.job.update({
    where:{ id },
    data:{ status:'closed' }
  });
  res.json({ ok:true, data:job });
});

// DELETE
router.delete('/:id', authMiddleware, requireHR, async (req, res) => {
  const prisma = req.app.locals.prisma;
  const id = Number(req.params.id);
  await prisma.job.delete({ where:{ id } });
  res.json({ ok:true });
});

module.exports = router;
