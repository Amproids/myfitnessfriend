#!/bin/bash
echo "=== Beginning deployment at $(date) ==="

# Navigate to project directory
cd ~/myfitnessfriendnet || exit 1

# Kill existing processes
echo "Killing existing processes..."
lsof -t -i:3002 | xargs kill -9 2>/dev/null || true
lsof -t -i:3001 | xargs kill -9 2>/dev/null || true

# Update from git with fetch and reset
echo "Fetching latest changes..."
git fetch origin
echo "Resetting to origin/main..."
git reset --hard origin/main

# Set permissions for scripts
echo "Setting script permissions..."
chmod 775 redeploy.sh || true

# Start server using nohup to keep it running
echo "Starting server..."
cd server || exit 1
nohup npm run start > ../server.log 2>&1 &
SERVER_PID=$!
echo "Server started with PID: $SERVER_PID"

# Start client build
echo "Building client..."
cd ../client || exit 1
npm run build &
BUILD_PID=$!

# Wait for build to complete
echo "Waiting for build to complete..."
wait $BUILD_PID
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "Build completed successfully"
    # Save the server PID to a file
    echo $SERVER_PID > ../server.pid
else
    echo "Build failed with status $BUILD_STATUS"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
fi

echo "=== Deployment completed at $(date) ==="
# Ensure the script stays alive long enough for processes to start
sleep 5
cd ~/myfitnessfriendnet
chmod 777 redeploy.sh
