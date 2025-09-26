# HRM Recruit

Ứng dụng quản lý & tuyển dụng nhân sự (Mobile + Server).

## Cấu trúc
- `hrm_recruit_app/`: Ứng dụng di động Flutter.
- `server/`: Backend Node.js/Express (API + DB).

## Yêu cầu
- Flutter >= 3.x
- Node.js >= 18
- PostgreSQL (hoặc SQLite khi dev)

## Cách chạy

### Server
```bash
cd server
cp .env.example .env
npm install
npx prisma generate
thêm .env để cài đặt môi trường
npm run dev
