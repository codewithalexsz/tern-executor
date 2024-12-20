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
    echo -e "\033[0;31mAn error occurred. Exiting script.\033[0m" >&2
    exit 1
}

# Trap errors and execute the handle_error function
trap 'handle_error' ERR

# Function to set environment variables
set_environment_variables() {
    run_with_delay export EXECUTOR_MAX_L3_GAS_PRICE=250
    run_with_delay export NODE_ENV=testnet
    run_with_delay export LOG_LEVEL=debug
    run_with_delay export LOG_PRETTY=false
    run_with_delay export EXECUTOR_PROCESS_ORDERS=true
    run_with_delay export EXECUTOR_PROCESS_CLAIMS=true
    run_with_delay export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'
    run_with_delay export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
}

# Function to get the latest release and the immediate previous release
fetch_releases() {
    echo "Fetching releases from GitHub..."
    RELEASES=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases | grep "tag_name" | awk -F '"' '{print $4}')
    LATEST_RELEASE=$(echo "$RELEASES" | head -n 1)
    PREVIOUS_RELEASE=$(echo "$RELEASES" | head -n 2 | tail -n 1)
}

# Function to install the Tern Executor
install_executor() {
    fetch_releases

    echo -e "\033[1;34mAvailable releases:\033[0m"
    echo "1) Latest Release: $LATEST_RELEASE"
    echo "2) Previous Release: $PREVIOUS_RELEASE"
    read -p "Select the release to install (1 or 2): " RELEASE_CHOICE

    case $RELEASE_CHOICE in
        1) SELECTED_RELEASE=$LATEST_RELEASE ;;
        2) SELECTED_RELEASE=$PREVIOUS_RELEASE ;;
        *) echo -e "\033[1;31mInvalid choice. Exiting.\033[0m"; exit 1 ;;
    esac

    echo "Cleaning up previous installations..."
    rm -rf executor-linux-*.tar.gz executor

    echo "Downloading and installing $SELECTED_RELEASE..."
    run_with_delay wget https://github.com/t3rn/executor-release/releases/download/$SELECTED_RELEASE/executor-linux-$SELECTED_RELEASE.tar.gz
    run_with_delay tar -xvzf executor-linux-$SELECTED_RELEASE.tar.gz

    cd executor/executor/bin || exit

    echo "Setting up environment variables..."
    set_environment_variables

    echo -e "\033[1;32mInstallation completed for $SELECTED_RELEASE.\033[0m"
    sleep 3
    main_menu
}

# Function to change the private key variable
change_private_key() {
    read -p "Enter your new private key: " PRIVATE_KEY_LOCAL
    export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
    echo -e "\033[1;32mPrivate key updated successfully.\033[0m"
    sleep 3
    main_menu
}

# Function to edit EXECUTOR_MAX_L3_GAS_PRICE
edit_max_l3_gas_price() {
    echo -e "\033[1;34mDefault is 10. For optimum transactions, set between 100-300.\033[0m"
    read -p "Enter the new value for EXECUTOR_MAX_L3_GAS_PRICE: " NEW_GAS_PRICE
    if [[ $NEW_GAS_PRICE =~ ^[0-9]+$ ]] && [ "$NEW_GAS_PRICE" -ge 10 ]; then
        export EXECUTOR_MAX_L3_GAS_PRICE=$NEW_GAS_PRICE
        echo -e "\033[1;32mEXECUTOR_MAX_L3_GAS_PRICE updated to $NEW_GAS_PRICE.\033[0m"
    else
        echo -e "\033[1;31mInvalid input. Please enter a valid number (10 or higher).\033[0m"
    fi
    sleep 3
    main_menu
}

# Function to start the executor
start_executor() {
    if [ -d "executor/executor/bin" ]; then
        cd executor/executor/bin || exit
        ./executor
    else
        echo -e "\033[1;31mExecutor is not installed. Please install it first using Option 1.\033[0m"
        sleep 3
        main_menu
    fi
}

# Function to check updates
check_update() {
    fetch_releases
    if [ -f executor-linux-*.tar.gz ]; then
        INSTALLED_VERSION=$(ls executor-linux-*.tar.gz | sed 's/executor-linux-//g' | sed 's/.tar.gz//g')
        echo -e "\033[1;34mCurrent Installed Version:\033[0m $INSTALLED_VERSION"
    else
        echo -e "\033[1;31mNo version is currently installed.\033[0m"
    fi
    echo -e "\033[1;34mLatest Release Available:\033[0m $LATEST_RELEASE"
    sleep 3
    main_menu
}

# Function to display the main menu
main_menu() {
    echo -e "\033[1;34mSelect an option:\033[0m"
    echo "1) Install Tern Executor"
    echo "2) Change Private Key"
    echo "3) Start Executor"
    echo "4) Check Update"
    echo "5) Edit EXECUTOR_MAX_L3_GAS_PRICE"
    echo "6) Exit"
    read -p "Enter your choice (1-6): " USER_CHOICE

    case $USER_CHOICE in
        1) install_executor ;;
        2) change_private_key ;;
        3) start_executor ;;
        4) check_update ;;
        5) edit_max_l3_gas_price ;;
        6) echo -e "\033[1;32mExiting script. Goodbye!\033[0m"; exit 0 ;;
        *) echo -e "\033[1;31mInvalid choice. Please try again.\033[0m"; sleep 2; main_menu ;;
    esac
}

# Start the main menu
main_menu