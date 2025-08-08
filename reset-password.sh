#!/bin/bash

# WordPress Admin Password Reset Script
# This script uses WP-CLI to reset the admin password

echo "Resetting WordPress admin password..."

# Check if WP-CLI is available
if command -v wp &> /dev/null; then
    echo "WP-CLI found, using WP-CLI method..."
    
    # Change to WordPress directory
    cd /var/www/html
    
    # Reset admin user password
    wp user update admin --user_pass=admin123 --allow-root
    
    # If admin user doesn't exist, create it
    if [ $? -ne 0 ]; then
        echo "Admin user not found, creating new admin user..."
        wp user create admin admin@example.com --role=administrator --user_pass=admin123 --allow-root
    fi
    
    echo "Password reset complete!"
    echo "Username: admin"
    echo "Password: admin123"
else
    echo "WP-CLI not found. Please use the reset-admin-password.php file instead."
    echo "Access it via: http://localhost:8080/reset-admin-password.php"
fi