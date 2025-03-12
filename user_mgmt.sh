#!/bin/bash

# Automated User Management System with Inactivity Detection
# Author: [Your Name]
# Description: Creates, deletes, locks, unlocks users, and detects inactive accounts.

LOG_FILE="/var/log/user_mgmt.log"
INACTIVE_DAYS=30  # Set inactivity threshold (days)

# Function to log actions
log_action() {
    echo "$(date) - $1" | tee -a "$LOG_FILE"
}

# Function to create a new user
create_user() {
    read -p "Enter the username to create: " USERNAME
    sudo useradd "$USERNAME"

    if [ $? -eq 0 ]; then
        PASSWORD=$(openssl rand -base64 12)
        echo "$USERNAME:$PASSWORD" | sudo chpasswd
        log_action "User '$USERNAME' created with a random password."
        echo "User '$USERNAME' created successfully! Password: $PASSWORD"
    else
        log_action "Failed to create user '$USERNAME'."
        echo "Error: Could not create user '$USERNAME'."
    fi
}

# Function to delete a user
delete_user() {
    read -p "Enter the username to delete: " USERNAME
    sudo userdel -r "$USERNAME"

    if [ $? -eq 0 ]; then
        log_action "User '$USERNAME' deleted."
        echo "User '$USERNAME' deleted successfully."
    else
        log_action "Failed to delete user '$USERNAME'."
        echo "Error: Could not delete user '$USERNAME'."
    fi
}

# Function to lock a user
lock_user() {
    read -p "Enter the username to lock: " USERNAME
    sudo passwd -l "$USERNAME"

    if [ $? -eq 0 ]; then
        log_action "User '$USERNAME' locked."
        echo "User '$USERNAME' has been locked."
    else
        log_action "Failed to lock user '$USERNAME'."
        echo "Error: Could not lock user '$USERNAME'."
    fi
}

# Function to unlock a user
unlock_user() {
    read -p "Enter the username to unlock: " USERNAME
    sudo passwd -u "$USERNAME"

    if [ $? -eq 0 ]; then
        log_action "User '$USERNAME' unlocked."
        echo "User '$USERNAME' has been unlocked."
    else
        log_action "Failed to unlock user '$USERNAME'."
        echo "Error: Could not unlock user '$USERNAME'."
    fi
}

# Function to check and lock inactive users
check_inactive_users() {
    echo "Checking for inactive users..."
    INACTIVE_USERS=$(lastlog -b $INACTIVE_DAYS | awk 'NR>1 && $3=="**Never logged in**" {print $1}')

    for USER in $INACTIVE_USERS; do
        sudo passwd -l "$USER"
        log_action "User '$USER' locked due to inactivity ($INACTIVE_DAYS days)."
        echo "User '$USER' has been locked due to inactivity."
    done
}

# Main Menu
while true; do
    echo -e "\n=== Automated User Management ==="
    echo "1) Create User"
    echo "2) Delete User"
    echo "3) Lock User"
    echo "4) Unlock User"
    echo "5) Check & Lock Inactive Users"
    echo "6) Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) create_user ;;
        2) delete_user ;;
        3) lock_user ;;
        4) unlock_user ;;
        5) check_inactive_users ;;
        6) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
done

