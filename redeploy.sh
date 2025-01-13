#!/bin/bash
echo "=== Beginning deployment at $(date) ==="

# Navigate to project directory
cd /home/andrew/myfitnessfriend || exit 1

# Carefully kill only our specific port processes
echo "Stopping existing processes..."
for port in 3001 3002; do
    pkill -f ":$port" || true
done

# Pull latest code
echo "Pulling latest code..."
git pull origin main

# Start server
echo "Starting server..."
cd server || exit 1
npm install
NODE_ENV=production npm run start > ../server.log 2>&1 &

# Build and serve client
echo "Building and starting client..."
cd ../client || exit 1
npm install
npm run build
npm run start > ../client.log 2>&1 &

echo "=== Deployment completed at $(date) ==="