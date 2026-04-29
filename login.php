<?php
session_start();
include 'config/db.php';
$error = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email    = $_POST['email'];
    $password = $_POST['password'];
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    if ($user && $password == $user['password']) {
        $_SESSION['user_id'] = $user['user_id'];
        $_SESSION['role']    = $user['role'];
        $_SESSION['name']    = $user['full_name'];
        if ($user['role'] == 'admin') {
            header("Location: admin/dashboard.php");
        } else {
            header("Location: pages/vehicles.php");
        }
        exit();
    } else {
        $error = "Email ya Password galat hai!";
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Vehicle Rental</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="form-box">
    <h2>Vehicle Rental Login</h2>
    <?php if($error): ?>
        <div class="error-msg"><?= $error ?></div>
    <?php endif; ?>
    <form method="POST">
        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>
    <br>
    <p style="text-align:center">
        Account nahi? <a href="register.php">Register karo</a>
    </p>
</div>
</body>
</html>