#!/bin/bash
set -e

# Start both dev servers
echo "Starting dev servers..."

# Start server
cd server
npm install
npm run dev &

# Start client
cd ../client
npm install
npm run dev &

echo "Dev environment ready"