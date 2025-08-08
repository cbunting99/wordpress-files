<?php
/**
 * WordPress Admin Password Reset Script
 * 
 * This script resets the admin user password to 'admin123'
 * Run this file by accessing it in your browser or via command line
 */

// Try to find WordPress root directory
$wp_root_paths = array(
    dirname( __FILE__ ) . '/wp-load.php',
    '/var/www/html/wp-load.php',
    $_SERVER['DOCUMENT_ROOT'] . '/wp-load.php'
);

$wp_loaded = false;
foreach ( $wp_root_paths as $wp_path ) {
    if ( file_exists( $wp_path ) ) {
        require_once( $wp_path );
        $wp_loaded = true;
        break;
    }
}

if ( ! $wp_loaded ) {
    die( 'WordPress not found. Please ensure this script is in the WordPress root directory.' );
}

echo "<h2>WordPress Admin Password Reset</h2>";

// Check if we can find an admin user
$admin_users = get_users( array(
    'role' => 'administrator',
    'number' => 1
) );

if ( empty( $admin_users ) ) {
    // No admin user found, create one
    echo "<p>No admin user found. Creating new admin user...</p>";
    
    $user_data = array(
        'user_login' => 'admin',
        'user_pass' => 'admin123',
        'user_email' => 'admin@example.com',
        'display_name' => 'Administrator',
        'role' => 'administrator'
    );
    
    $user_id = wp_insert_user( $user_data );
    
    if ( is_wp_error( $user_id ) ) {
        echo "<p style='color: red;'>Error creating admin user: " . $user_id->get_error_message() . "</p>";
    } else {
        echo "<p style='color: green;'>Admin user created successfully!</p>";
        echo "<p><strong>Username:</strong> admin</p>";
        echo "<p><strong>Password:</strong> admin123</p>";
    }
} else {
    // Update existing admin user
    $admin_user = $admin_users[0];
    echo "<p>Found admin user: " . $admin_user->user_login . "</p>";
    
    // Reset password
    wp_set_password( 'admin123', $admin_user->ID );
    
    // Also update username to 'admin' if it's different
    if ( $admin_user->user_login !== 'admin' ) {
        wp_update_user( array(
            'ID' => $admin_user->ID,
            'user_login' => 'admin'
        ) );
        echo "<p>Username updated to 'admin'</p>";
    }
    
    echo "<p style='color: green;'>Admin password reset successfully!</p>";
    echo "<p><strong>Username:</strong> admin</p>";
    echo "<p><strong>Password:</strong> admin123</p>";
}

echo "<p><a href='" . wp_login_url() . "'>Go to WordPress Login</a></p>";
echo "<p><a href='" . admin_url() . "'>Go to WordPress Admin</a></p>";

// Security: Delete this file after use
echo "<hr>";
echo "<p style='color: orange;'><strong>Security Notice:</strong> Please delete this file after use for security reasons.</p>";
echo "<p>File location: " . __FILE__ . "</p>";

?>