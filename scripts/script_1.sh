#!/bin/bash

# Checks if it is the root user
check_root_user() {
    echo ""
    echo "┌┬┐┬─┐┬┌─┐┬  ┌─┐┌─┐┬ ┬┌─┐┬─┐┌─┐"
    echo " │ ├┬┘│├─┘│  └─┐├─┘├─┤├┤ ├┬┘├┤ "
    echo " ┴ ┴└─┴┴  ┴─┘└─┘┴  ┴ ┴└─┘┴└─└─┘"
    echo ""
    echo "┌─┐┌─┐┬─┐┬┌─┐┌┬┐  ┌─┐┌┐┌┌─┐  ┬┌─┐  ┌─┐┌┬┐┌─┐┬─┐┌┬┐┌─┐┌┬┐";
    echo "└─┐│  ├┬┘│├─┘ │   │ ││││├┤   │└─┐  └─┐ │ ├─┤├┬┘ │ ├┤  ││";
    echo "└─┘└─┘┴└─┴┴   ┴   └─┘┘└┘└─┘  ┴└─┘  └─┘ ┴ ┴ ┴┴└─ ┴ └─┘─┴┘";
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┌─┐┬ ┬┌─┐┌─┐┬┌─    ┬─┐┌─┐┌─┐┌┬┐   ┬ ┬┌─┐┌─┐┬─┐";
    echo "│  │ │├─┤ │││││││ ┬  │  ├─┤├┤ │  ├┴┐    ├┬┘│ ││ │ │    │ │└─┐├┤ ├┬┘";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘┴ ┴└─┘└─┘┴ ┴────┴└─└─┘└─┘ ┴────└─┘└─┘└─┘┴└─";
    echo ""
    read -p "Are you logged in as root? (yes/no): " response
    echo ""

    case "$response" in
        no)
            echo ""
            echo "Please log in as root to run this script."
            echo ""
            exit 1
            ;;
        yes)
            if [[ $EUID -ne 0 ]]; then
                echo ""
                echo "You are not logged in as root."
                echo ""
                exit 1
            else
                echo ""
                echo "You are logged in as root. The script continues."
                echo ""
            fi
            ;;
        *)
            echo ""
            echo "Invalid response."
            echo ""
            exit 1
            ;;
    esac
}

# Function for checking and configuring the locale
configure_locale() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┬ ┬┬─┐┌─┐    ┬  ┌─┐┌─┐┌─┐┬  ┌─┐  ┌─┐┬ ┬┌┐┌┌─┐┌┬┐┬┌─┐┌┐┌";
    echo "│  │ │├─┤ │││││││ ┬  │  │ ││││├┤ ││ ┬│ │├┬┘├┤     │  │ ││  ├─┤│  ├┤   ├┤ │ │││││   │ ││ ││││";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘└─┘┘└┘└  ┴└─┘└─┘┴└─└─┘────┴─┘└─┘└─┘┴ ┴┴─┘└─┘  └  └─┘┘└┘└─┘ ┴ ┴└─┘┘└┘";
    echo ""
    echo "Checking locale..."

    current_locale=$(locale | grep LANG= | cut -d "=" -f2)

    echo ""
    echo "Current locale: $current_locale"
    echo ""

    read -p "Do you want to keep this locale? (yes/no): " response
    echo ""

    case "$response" in
        "no")
            read -p "Enter the new locale (e.g., en_US.UTF-8): " new_locale
            echo ""

            # Validate the format of the new locale
            if ! [[ "$new_locale" =~ ^[a-zA-Z]{2}_[a-zA-Z]{2}\.(UTF|utf)-8$ ]]; then
                echo ""
                echo "Invalid locale format. Aborting script."
                echo ""
                exit 1
            fi

            echo ""
            echo "Generating new locale: $new_locale"
            sudo locale-gen "$new_locale"
            sudo update-locale LANG="$new_locale"
            echo ""
            echo "Locale has been configured successfully."
            echo ""
            ;;
        "yes")
            echo ""
            echo "Keeping the current locale: $current_locale"
            echo ""
            echo "Locale is already configured."
            echo ""
            ;;
        *)
            echo ""
            echo "Invalid response. Aborting script."
            echo ""
            exit 1
            ;;
    esac
}

# Function for updating and installing packages
update_and_install_packages() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┬ ┬┌─┐┌┬┐┌─┐┌┬┐┌─┐    ┌─┐┌┐┌┌┬┐    ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┬      ┌─┐┌─┐┌─┐┬┌─┌─┐┌─┐┌─┐┌─┐";
    echo "│  │ │├─┤ │││││││ ┬  │ │├─┘ ││├─┤ │ ├┤     ├─┤│││ ││    ││││└─┐ │ ├─┤│  │      ├─┘├─┤│  ├┴┐├─┤│ ┬├┤ └─┐";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘┴  ─┴┘┴ ┴ ┴ └─┘────┴ ┴┘└┘─┴┘────┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴─┘────┴  ┴ ┴└─┘┴ ┴┴ ┴└─┘└─┘└─┘";
    echo ""
    echo "Updating repository and upgrading system..."
    echo ""
    sudo apt update
    sudo apt full-upgrade -y
    echo "Checking required packages..."
    echo ""

    required_packages=("sudo" "ufw" "fail2ban")

    for package in "${required_packages[@]}"; do
        if ! dpkg -s "$package" &> /dev/null; then
            echo ""
            read -p "Package '$package' is not installed. Do you want to install it? (yes/no): " response
            echo ""
            
            case "$response" in
                yes)
                    sudo apt install "$package" -y
                    echo ""
                    echo "Package '$package' has been installed."
                    echo ""
                    ;;
                no)
                    echo ""
                    echo "Skipping installation of package '$package'."
                    echo ""
                    ;;
                *)
                    echo ""
                    echo "Invalid response. Please enter 'yes' or 'no'."
                    echo ""
                    ;;
            esac
        fi
    done
    
    echo ""
    echo "Package installation completed."
    echo ""
    
    # Additional package installation
    while true; do
        echo ""
        read -p "Do you want to install additional packages? (yes/no): " response
        echo ""
        
        case "$response" in
            no)
                break
                ;;
            yes)
                echo ""
                read -p "Enter the package name to install: " package_name
                echo ""
                
                if sudo apt-cache show "$package_name" &> /dev/null; then
                    sudo apt install "$package_name" -y
                    echo ""
                    echo "Package '$package_name' has been installed."
                    echo ""
                else
                    echo ""
                    echo "Package '$package_name' is not available in the repositories."
                    echo ""
                fi
                ;;
            *)
                echo ""
                echo "Invalid response. Please enter 'yes' or 'no'."
                echo ""
                ;;
        esac
    done
    
    echo ""
    echo "All installations are completed."
    echo ""
}

# Function for checking and configuring users
configure_users() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┬ ┬┬─┐┌─┐    ┬ ┬┌─┐┌─┐┬─┐┌─┐"
    echo "│  │ │├─┤ │││││││ ┬  │  │ ││││├┤ ││ ┬│ │├┬┘├┤     │ │└─┐├┤ ├┬┘└─┐"
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘└─┘┘└┘└  ┴└─┘└─┘┴└─└─┘────└─┘└─┘└─┘┴└─└─┘"
    echo ""
    echo "Configuring users..."
    echo ""
    
    read -p "How many users do you want to create? (Maximum 10): " user_count
    echo ""
    
    if ! [[ "$user_count" =~ ^[1-9]$|^10$ ]]; then
        echo ""
        echo "Invalid input. Please enter a number between 1 and 10."
        echo ""
        exit 1
    fi
    
    created_users=()
    
    for ((i=1; i<=user_count; i++)); do
        echo ""
        read -p "Enter the username for User $i: " username
        echo ""
        read -s -p "Enter the password for User $username: " user_password
        echo ""

        if id "$username" &> /dev/null; then
            echo ""
            echo "User '$username' already exists. Skipping creation."
            echo ""
        else
            sudo adduser --disabled-password --gecos "" "$username"
            echo ""
            echo "$username:$user_password" | sudo chpasswd
            echo ""
            created_users+=("$username")
        fi
    done
    
    echo ""
    echo "All users have been created."
    echo ""
    
    echo ""
    read -p "Do you want to grant sudo privileges to any of the users? (yes/no): " response
    echo ""
    
    if [[ "$response" == "yes" ]]; then
        echo ""
        read -p "Enter the usernames of the users you want to give sudo privileges (comma-separated): " sudo_users
        echo ""
        
        IFS=',' read -ra users_array <<< "$sudo_users"
        
        for user in "${users_array[@]}"; do
            if [[ " ${created_users[*]} " == *" $user "* ]]; then
                sudo usermod -aG sudo "$user"
                echo ""
                echo "User '$user' has been granted sudo privileges."
                echo ""
            else
                echo ""
                echo "User '$user' was not created. Cannot grant sudo privileges."
                echo ""
            fi
        done
    else
        echo ""
        echo "No users have been granted sudo privileges."
        echo ""
    fi
    
    echo ""
    echo "Users configuration completed."
    echo ""
}

# Configure SSH folder structure for users
configure_users_ssh() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┬ ┬┬─┐┌─┐    ┬ ┬┌─┐┌─┐┬─┐┌─┐    ┌─┐┌─┐┬ ┬";
    echo "│  │ │├─┤ │││││││ ┬  │  │ ││││├┤ ││ ┬│ │├┬┘├┤     │ │└─┐├┤ ├┬┘└─┐    └─┐└─┐├─┤";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘└─┘┘└┘└  ┴└─┘└─┘┴└─└─┘────└─┘└─┘└─┘┴└─└─┘────└─┘└─┘┴ ┴";
    echo ""
    echo "Configuring SSH folder structure for users..."
    echo ""

    # Array to store selected users
    selected_users=()

    while :; do
        echo ""
        read -p "Enter the username for the user to configure (or type 'READY' to finish): " username
        echo ""

        if [ "$username" = "READY" ]; then
            break
        fi

        # Check if the user exists in created_users array
        if [[ "${created_users[*]}" =~ (^|[[:space:]])"$username"($|[[:space:]]) ]]; then
            selected_users+=("$username")
        else
            echo ""
            echo "User '$username' does not exist or was not created. Please enter a valid username."
            echo ""
        fi
    done

    if [ ${#selected_users[@]} -eq 0 ]; then
        echo ""
        echo "No users selected for SSH configuration."
        echo ""
        return
    fi

    # Configure SSH for the selected users
    for user in "${selected_users[@]}"; do
        sudo mkdir -p "/home/$user/.ssh"
        sudo chown -R "$user:$user" "/home/$user/.ssh"
        sudo chmod 700 "/home/$user/.ssh"
        sudo touch "/home/$user/.ssh/authorized_keys"
        sudo chown "$user:$user" "/home/$user/.ssh/authorized_keys"
        sudo chmod 600 "/home/$user/.ssh/authorized_keys"
    done

    echo ""
    echo "SSH folder structure configuration completed."
    echo ""
}

# Function to remove small Diffie-Hellman moduli
remove_hellman() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┬─┐┌─┐┌┬┐┌─┐┬  ┬┌─┐    ┬ ┬┌─┐┬  ┬  ┌┬┐┌─┐┌┐┌";
    echo "│  │ │├─┤ │││││││ ┬  ├┬┘├┤ ││││ │└┐┌┘├┤     ├─┤├┤ │  │  │││├─┤│││";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  ┴└─└─┘┴ ┴└─┘ └┘ └─┘────┴ ┴└─┘┴─┘┴─┘┴ ┴┴ ┴┘└┘";
    echo ""
    echo "Removing small Diffie-Hellman..."
    echo ""
    sudo awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
    sudo mv /etc/ssh/moduli.safe /etc/ssh/moduli
    echo ""
    echo "Successfully removed Diffie-Hellman moduli."
    echo ""
}

# Function to regenerate the SSH host keys
regenerate_ssh_keys() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┬─┐┌─┐┌─┐┌─┐┌┐┌┌─┐┬─┐┌─┐┌┬┐┌─┐    ┌─┐┌─┐┬ ┬    ┬┌─┌─┐┬ ┬┌─┐";
    echo "│  │ │├─┤ │││││││ ┬  ├┬┘├┤ │ ┬├┤ │││├┤ ├┬┘├─┤ │ ├┤     └─┐└─┐├─┤    ├┴┐├┤ └┬┘└─┐";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  ┴└─└─┘└─┘└─┘┘└┘└─┘┴└─┴ ┴ ┴ └─┘────└─┘└─┘┴ ┴────┴ ┴└─┘ ┴ └─┘";
    echo""
    echo "Regenerating SSH host keys..."
    echo ""
    sudo rm /etc/ssh/ssh_host_*
    sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    echo ""
    echo "SSH host keys regenerated."
    echo ""
}

# Function to check if all previous functions were successful
check_all_functions_completed() {
    echo ""
    echo "┬  ┌─┐┌─┐┌┬┐┬┌┐┌┌─┐  ┌─┐┬ ┬┌─┐┌─┐┬┌─    ┌─┐┬  ┬      ┌─┐┬ ┬┌┐┌┌─┐┌┬┐┬┌─┐┌┐┌┌─┐    ┌─┐┌─┐┌┬┐┌─┐┬  ┌─┐┌┬┐┌─┐┌┬┐";
    echo "│  │ │├─┤ │││││││ ┬  │  ├─┤├┤ │  ├┴┐    ├─┤│  │      ├┤ │ │││││   │ ││ ││││└─┐    │  │ ││││├─┘│  ├┤  │ ├┤  ││";
    echo "┴─┘└─┘┴ ┴─┴┘┴┘└┘└─┘  └─┘┴ ┴└─┘└─┘┴ ┴────┴ ┴┴─┘┴─┘────└  └─┘┘└┘└─┘ ┴ ┴└─┘┘└┘└─┘────└─┘└─┘┴ ┴┴  ┴─┘└─┘ ┴ └─┘─┴┘";
    echo ""
    local success=true

    # Check root user
    if ! check_root_user; then
        echo ""
        echo "Error: check_root_user function failed."
        echo ""
        success=false
    fi

    # Check locale configuration
    if ! configure_locale; then
        echo ""
        echo "Error: configure_locale function failed."
        echo ""
        success=false
    fi

    # Check package update and installation
    if ! update_and_install_packages; then
        echo ""
        echo "Error: update_and_install_packages function failed."
        echo ""
        success=false
    fi

    # Check user configuration
    if ! configure_users; then
        echo ""
        echo "Error: configure_users function failed."
        echo ""
        success=false
    fi

    # Check SSH configuration for users
    if ! configure_users_ssh; then
        echo ""
        echo "Error: configure_users_ssh function failed."
        echo ""
        success=false
    fi

    # Check removal of small Diffie-Hellman
    if ! remove_hellman; then
        echo ""
        echo "Error: remove_hellman function failed."
        echo ""
        success=false
    fi

    if $success; then
        echo ""
        echo "All previous functions completed successfully."
        echo ""
        exit 0
    else
        echo ""
        echo "Some previous functions were not completed successfully."
        echo ""
        exit 1
    fi
}

# Message
message() {
    echo ""
    echo "┌─┐┌─┐┬─┐┬┌─┐┌┬┐  ┌─┐┌┐┌┌─┐  ┌─┐┬ ┬┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┬ ┬┬  ";
    echo "└─┐│  ├┬┘│├─┘ │   │ ││││├┤   └─┐│ ││  │  ├┤ └─┐└─┐├┤ │ ││  ";
    echo "└─┘└─┘┴└─┴┴   ┴   └─┘┘└┘└─┘  └─┘└─┘└─┘└─┘└─┘└─┘└─┘└  └─┘┴─┘";
    echo ""
    echo "╔╦╗┬ ┬┌─┐┌┐┌┬┌─┌─┐  ┌─┐┌─┐┬─┐  ┬ ┬┌─┐┬ ┬┬─┐  ┌─┐┌─┐┌┐┌┌─┐┬┌┬┐┌─┐┌┐┌┌─┐┌─┐";
    echo " ║ ├─┤├─┤│││├┴┐└─┐  ├┤ │ │├┬┘  └┬┘│ ││ │├┬┘  │  │ ││││├┤ │ ││├┤ ││││  ├┤ ";
    echo " ╩ ┴ ┴┴ ┴┘└┘┴ ┴└─┘  └  └─┘┴└─   ┴ └─┘└─┘┴└─  └─┘└─┘┘└┘└  ┴─┴┘└─┘┘└┘└─┘└─┘";
    echo ""
    echo "┌┬┐┬─┐┬┌─┐┬  ┌─┐┌─┐┬ ┬┌─┐┬─┐┌─┐";
    echo " │ ├┬┘│├─┘│  └─┐├─┘├─┤├┤ ├┬┘├┤ ";
    echo " ┴ ┴└─┴┴  ┴─┘└─┘┴  ┴ ┴└─┘┴└─└─┘";
    echo ""
}

# Main function to perform all configuration steps
run_configuration() {
    check_root_user
    configure_locale
    update_and_install_packages
    configure_users
    configure_users_ssh
    remove_hellman
    regenerate_ssh_keys
    check_all_functions_completed
    message
}

# Starts the main program
run_configuration