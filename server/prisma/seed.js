// prisma/seed.js
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  const plain = '123456@Abc'; 
  const hashed = await bcrypt.hash(plain, 10);

  const user = await prisma.user.upsert({
    where: { email: 'hr@company.com' },
    update: {},
    create: {
      email: 'hr@company.com',
      password: hashed,
      name: 'HR Default',
      role: 'HR'
    }
  });

  console.log('Seeded HR user:', { email: user.email, password: plain });
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
