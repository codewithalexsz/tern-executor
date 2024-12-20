To make the script dynamically remove the previously installed version regardless of its version number, you can modify the install_executor function to identify and remove any existing tar.gz files or directories related to prior installations. Here's the updated script:

#!/bin/bash

# Enable error trapping
set -e

# Function to run a command with a 5-second delay after completion
run_with_delay() {
    "$@"
    sleep 5
}

# Function to handle errors
handle_error() {
    echo "An error occurred. Exiting script." >&2
    exit 1
}

# Trap errors and execute the handle_error function
trap 'handle_error' ERR

# Function to install the Tern Executor
install_executor() {
    # Check if any existing tar.gz files or extracted directories exist and remove them
    echo "Cleaning up previous installations..."
    rm -rf executor-linux-*.tar.gz executor

    # Get the latest release tag from GitHub
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')
    echo "Latest release found: $LATEST_RELEASE"

    # Download the new tar.gz file
    run_with_delay wget https://github.com/t3rn/executor-release/releases/download/$LATEST_RELEASE/executor-linux-$LATEST_RELEASE.tar.gz

    # Extract the tar.gz file
    run_with_delay tar -xvzf executor-linux-$LATEST_RELEASE.tar.gz

    # Navigate to the executor directory
    cd executor/executor/bin || exit

    # Set environment variables
    run_with_delay export EXECUTOR_MAX_L3_GAS_PRICE=10
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

    echo "Installation completed. You can now start the executor."
}

# Function to start the executor
start_executor() {
    cd executor/executor/bin || exit
    ./executor
}

# Function to update to the latest release
update_executor() {
    echo "Checking for the latest release..."

    # Get the latest release tag from GitHub
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')
    echo "Latest release found: $LATEST_RELEASE"

    # Clean up previous installations
    echo "Cleaning up previous installations..."
    rm -rf executor-linux-*.tar.gz executor

    # Download the latest tar.gz file
    run_with_delay wget https://github.com/t3rn/executor-release/releases/download/$LATEST_RELEASE/executor-linux-$LATEST_RELEASE.tar.gz

    # Extract the tar.gz file
    run_with_delay tar -xvzf executor-linux-$LATEST_RELEASE.tar.gz

    echo "Update completed. You can now start the executor."
}

# Main menu
echo "Select an option:"
echo "1) Install Tern Executor"
echo "2) Start Executor"
echo "3) Update to Latest Release"
read -p "Enter your choice (1, 2, or 3): " USER_CHOICE

case $USER_CHOICE in
    1)
        install_executor
        ;;
    2)
        start_executor
        ;;
    3)
        update_executor
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

Key Updates:

1. Dynamic Cleanup:

Deletes all files matching the pattern executor-linux-*.tar.gz.

Removes the executor directory to ensure no leftovers from previous versions.



2. Version-Agnostic:

No hardcoded version numbers. Automatically handles any prior version of the executor.



3. Unified Cleanup:

Both install_executor and update_executor clean up any previous installation before proceeding.




Workflow:

During installation or update, the script removes all previous tar.gz files and directories to ensure a fresh setup.


