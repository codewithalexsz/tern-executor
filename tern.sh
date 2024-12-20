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
    echo "5) Exit"
    read -p "Enter your choice (1-5): " USER_CHOICE

    case $USER_CHOICE in
        1) install_executor ;;
        2) change_private_key ;;
        3) start_executor ;;
        4) check_update ;;
        5) echo -e "\033[1;32mExiting script. Goodbye!\033[0m"; exit 0 ;;
        *) echo -e "\033[1;31mInvalid choice. Please try again.\033[0m"; sleep 2; main_menu ;;
    esac
}

# Start the main menu
main_menu