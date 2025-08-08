<?php
/**
 * Direct Database Admin Password Reset
 * 
 * This script directly updates the database to reset admin password
 * Use this if the WordPress method doesn't work
 */

// Database configuration (from docker-compose.yml)
$db_host = 'localhost';
$db_user = 'wordpress';
$db_pass = 'wordpress123';
$db_name = 'wordpress';

echo "<h2>Direct Database Password Reset</h2>";

try {
    // Connect to database
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p>Connected to database successfully.</p>";
    
    // Get table prefix
    $stmt = $pdo->query("SHOW TABLES LIKE '%users'");
    $table = $stmt->fetch(PDO::FETCH_NUM);
    
    if ($table) {
        $users_table = $table[0];
        $prefix = str_replace('users', '', $users_table);
        echo "<p>Found users table: $users_table</p>";
        echo "<p>Table prefix: " . ($prefix ?: 'none') . "</p>";
        
        // Hash the password
        $password = 'admin123';
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        
        // Check if admin user exists
        $stmt = $pdo->prepare("SELECT ID, user_login FROM $users_table WHERE user_login = 'admin' OR ID = 1 LIMIT 1");
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            // Update existing user
            $stmt = $pdo->prepare("UPDATE $users_table SET user_login = 'admin', user_pass = ? WHERE ID = ?");
            $stmt->execute([$hashed_password, $user['ID']]);
            
            echo "<p style='color: green;'>Admin password updated successfully!</p>";
            echo "<p><strong>User ID:</strong> " . $user['ID'] . "</p>";
        } else {
            // Create new admin user
            $stmt = $pdo->prepare("INSERT INTO $users_table (user_login, user_pass, user_nicename, user_email, user_registered, display_name) VALUES ('admin', ?, 'admin', 'admin@example.com', NOW(), 'Administrator')");
            $stmt->execute([$hashed_password]);
            
            $user_id = $pdo->lastInsertId();
            
            // Add admin capabilities
            $usermeta_table = $prefix . 'usermeta';
            $stmt = $pdo->prepare("INSERT INTO $usermeta_table (user_id, meta_key, meta_value) VALUES (?, ?, ?)");
            $stmt->execute([$user_id, $prefix . 'capabilities', 'a:1:{s:13:"administrator";b:1;}']);
            $stmt->execute([$user_id, $prefix . 'user_level', '10']);
            
            echo "<p style='color: green;'>New admin user created successfully!</p>";
            echo "<p><strong>User ID:</strong> $user_id</p>";
        }
        
        echo "<p><strong>Username:</strong> admin</p>";
        echo "<p><strong>Password:</strong> admin123</p>";
        
    } else {
        echo "<p style='color: red;'>Could not find WordPress users table.</p>";
    }
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>Database error: " . $e->getMessage() . "</p>";
    echo "<p>Make sure the database is running and the credentials are correct.</p>";
}

echo "<p><a href='/wp-admin/'>Go to WordPress Admin</a></p>";
echo "<hr>";
echo "<p style='color: orange;'><strong>Security Notice:</strong> Please delete this file after use.</p>";

?>