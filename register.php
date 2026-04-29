<?php
session_start();
include 'config/db.php';
$error   = "";
$success = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name     = $_POST['full_name'];
    $email    = $_POST['email'];
    $password = $_POST['password'];
    $phone    = $_POST['phone'];

    // Email pehle se hai?
    $check = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $check->execute([$email]);

    if ($check->fetch()) {
        $error = "Yeh email pehle se registered hai!";
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO users (full_name, email, password, phone, role) 
            VALUES (?, ?, ?, ?, 'customer')
        ");
        $stmt->execute([$name, $email, $password, $phone]);
        $success = "Account ban gaya! Ab login karo.";
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="form-box">
    <h2>Register</h2>

    <?php if($error): ?>
        <div class="error-msg"><?= $error ?></div>
    <?php endif; ?>

    <?php if($success): ?>
        <div style="background:#d5f5e3;color:#1e8449;padding:10px;
                    border-radius:5px;margin-bottom:15px">
            <?= $success ?>
        </div>
    <?php endif; ?>

    <form method="POST">
        <input type="text"     name="full_name" placeholder="Full Name"  required>
        <input type="email"    name="email"     placeholder="Email"       required>
        <input type="password" name="password"  placeholder="Password"    required>
        <input type="text"     name="phone"     placeholder="Phone Number" required>
        <button type="submit">Register</button>
    </form>
    <br>
    <p style="text-align:center">
        Pehle se account hai? <a href="login.php">Login karo</a>
    </p>
</div>
</body>
</html>