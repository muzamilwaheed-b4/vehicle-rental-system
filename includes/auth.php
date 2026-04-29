<?php
session_start();

// Agar login nahi toh wapas bhejo
if (!isset($_SESSION['user_id'])) {
    header("Location: ../login.php");
    exit();
}

// Admin check ke liye
function isAdmin() {
    return $_SESSION['role'] == 'admin';
}
?>