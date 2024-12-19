#!/bin/bash

# Function to run a command with a 5-second delay after completion
run_with_delay() {
    "$@"
    sleep 5
}

# Remove old tar.gz file
run_with_delay rm -r executor-linux-v0.27.0.tar.gz

# Download the new tar.gz file
run_with_delay wget https://github.com/t3rn/executor-release/releases/download/v0.28.0/executor-linux-v0.28.0.tar.gz

# Extract the tar.gz file
run_with_delay tar -xvzf executor-linux-v0.28.0.tar.gz

# Navigate to the executor directory
cd executor/executor/bin || exit

# Set environment variables
run_with_delay export NODE_ENV=testnet
run_with_delay export LOG_LEVEL=debug
run_with_delay export LOG_PRETTY=false
run_with_delay export EXECUTOR_PROCESS_ORDERS=true
run_with_delay export EXECUTOR_PROCESS_CLAIMS=true
run_with_delay export EXECUTOR_MAX_L3_GAS_PRICE=50
run_with_delay export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'
run_with_delay export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false

# Ask the user for their private key
read -p "Enter your private key: " PRIVATE_KEY_LOCAL
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL

# Confirm action from the user
echo "RUN THE TERN EXECUTOR NOW?"
read -p "Type 'yes' to proceed, or 'no' to exit: " USER_CONFIRMATION

if [ "$USER_CONFIRMATION" = "yes" ]; then
    run_with_delay ./executor
else
    echo "Execution aborted."
fi
