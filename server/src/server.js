const app = require('./app');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const PORT = process.env.PORT || 4000;

async function start() {
  try {
    await prisma.$connect();
    console.log('✅ Prisma connected to MySQL');
    app.locals.prisma = prisma;
    const API_PREFIX = '/api';    

    app.listen(PORT, () => {
      console.log(`🚀 Server listening on http://localhost:${PORT}`);
    });
  } catch (e) {
    console.error('❌ Failed to start server', e);
    process.exit(1);
  }
}

start();
