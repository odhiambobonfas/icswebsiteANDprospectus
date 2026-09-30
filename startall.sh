#!/bin/bash

echo "========================================="
echo "  Starting ICS Website & Smart Prospectus"
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cleanup() {
  echo ""
  echo "Shutting down..."
  kill $CLIENT_PID $API_PID 2>/dev/null
  wait $CLIENT_PID $API_PID 2>/dev/null
  echo "Done."
}
trap cleanup EXIT INT TERM

# --- Smart Prospectus API ---
echo ""
echo "[API] Setting up Smart Prospectus on port 4000..."
cd "$SCRIPT_DIR/smart_prospectus"

export DATABASE_URL="postgresql://wizarddev:Othina78@localhost:5432/EduOs_Database"

npx prisma generate 2>&1 | sed 's/^/[API] /'
npx prisma db push --accept-data-loss 2>&1 | sed 's/^/[API] /'

echo "[API] Building..."
npm run build 2>&1 | sed 's/^/[API] /'

echo "[API] Starting Smart Prospectus..."
node dist/src/main.js &
API_PID=$!

# --- Client ---
echo ""
echo "[Client] Starting ICS Website on port 3031..."
cd "$SCRIPT_DIR/Futuristic-ICS-Website/client"

NEXT_PUBLIC_API_URL="http://localhost:4000" NEXT_PUBLIC_COURSES_API_URL="http://localhost:4000" npm run dev &
CLIENT_PID=$!

echo ""
echo "========================================="
echo "  Client:  http://localhost:3031"
echo "  API:     http://localhost:4000"
echo "  API Doc: http://localhost:4000/api"
echo "========================================="
echo "Press Ctrl+C to stop both."
echo ""

wait
