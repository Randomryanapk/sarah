<?php
session_start();

// Mock user credentials (for demonstration purposes)
$businessUser = "projectsarah";
$personalUser = "projectsarah";
$password = "projectsarah";

// Function to check if the device is Android
function isAndroidDevice() {
    $userAgent = $_SERVER['HTTP_USER_AGENT'];
    return stripos($userAgent, 'Android') !== false;
}

// Block non-Android devices
if (!isAndroidDevice()) {
    die("Access denied. This page is only accessible from Android devices.");
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $inputUsername = $_POST['username'];
    $inputPassword = $_POST['password'];
    $loginType = $_POST['login_type'];

    // Check credentials based on login type
    if (($loginType === 'business' && $inputUsername === $businessUser && $inputPassword === $password) ||
        ($loginType === 'personal' && $inputUsername === $personalUser && $inputPassword === $password)) {
        $_SESSION['loggedin'] = true;
        $_SESSION['login_type'] = $loginType;
        header("Location: cgi-admin2/dashboard.php"); // Redirect to dashboard
        exit();
    } else {
        $loginError = "Invalid username or password.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KOHO Login</title>
    <style>
        /* Basic Reset and Styling */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body, html { height: 100%; overflow: hidden; display: flex; align-items: center; justify-content: center; background-color: #1D1C3B; color: #FFFFFF; }

        /* Splash Screen Styles */
        .splash-screen {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #1D1C3B;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .splash-screen .loader {
            border: 4px solid #1D1C3B;
            border-top: 4px solid #D3FF3A;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Login Container */
        .login-container {
            display: none;
            text-align: center;
            background-color: #252447;
            padding: 40px;
            border-radius: 8px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.2);
        }
        .login-container h2 {
            color: #D3FF3A;
            margin-bottom: 20px;
        }
        .login-container button {
            width: 100%;
            padding: 10px;
            margin-top: 20px;
            background-color: #D3FF3A;
            color: #1D1C3B;
            border: none;
            border-radius: 5px;
            font-size: 18px;
            cursor: pointer;
        }
        .login-container button:hover {
            background-color: #c0e635;
        }
        .error-message {
            color: #FF3A3A;
            margin-top: 10px;
        }

        /* Login Form Fields */
        .login-form input[type="text"], .login-form input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            border: 1px solid #D3FF3A;
            background-color: #1D1C3B;
            color: #FFFFFF;
        }

        /* Toggle Buttons */
        .portal-buttons { display: flex; gap: 10px; justify-content: center; margin-bottom: 20px; }
        .portal-buttons button { flex: 1; padding: 10px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        .portal-buttons .business-btn { background-color: #D3FF3A; color: #1D1C3B; }
        .portal-buttons .personal-btn { background-color: #c0e635; color: #1D1C3B; }
        .portal-buttons button:hover { opacity: 0.9; }

        /* Contact Us Button */
        .contact-us-button {
            background-color: #4A4A75;
            color: #D3FF3A;
            padding: 10px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 15px;
            display: block;
            width: 100%;
            max-width: 400px;
            text-align: center;
            text-decoration: none;
        }
        .contact-us-button:hover {
            background-color: #5B5B89;
        }
    </style>
</head>
<body>

    <!-- Splash Screen -->
    <div class="splash-screen" id="splashScreen">
        <div class="loader"></div>
    </div>

    <!-- Login Container -->
    <div class="login-container" id="loginContainer">
        <h2>Login to KOHO</h2>

        <!-- Toggle between Business and Personal login forms -->
        <div class="portal-buttons">
            <button class="business-btn" onclick="showLoginForm('business')">Business</button>
            <button class="personal-btn" onclick="showLoginForm('personal')">Personal</button>
        </div>

        <!-- Login Form -->
        <form class="login-form" method="POST">
            <input type="hidden" id="loginType" name="login_type" value="">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
            <?php if (!empty($loginError)) { echo "<div class='error-message'>$loginError</div>"; } ?>
        </form>

        <!-- Contact Us Button -->
        <a href="contact_us.php" class="contact-us-button">Contact Us</a>
    </div>

    <script>
        // JavaScript to handle splash screen transition and login form display
        window.addEventListener("load", () => {
            const splashScreen = document.getElementById("splashScreen");
            const loginContainer = document.getElementById("loginContainer");

            // Hide splash screen after a delay and show the login options
            setTimeout(() => {
                splashScreen.style.display = "none";
                loginContainer.style.display = "block";
            }, 2000); // Adjust delay time if necessary
        });

        // Function to show login form based on type (Business or Personal)
        function showLoginForm(type) {
            document.getElementById('loginType').value = type;
            const formHeader = document.querySelector(".login-container h2");
            formHeader.textContent = type === 'business' ? 'Business Login' : 'Personal Login';
        }
    </script>
</body>
</html>
