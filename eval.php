<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dynamic Evaluation Vulnerability Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .warning {
            background-color: #ffebee;
            border: 1px solid #f44336;
            color: #c62828;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        button {
            background-color: #2196F3;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #1976D2;
        }
        .result {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
            border-left: 4px solid #2196F3;
        }
        .examples {
            background-color: #fff3e0;
            padding: 15px;
            border-radius: 4px;
            margin-top: 20px;
        }
        .examples h3 {
            margin-top: 0;
            color: #e65100;
        }
        .example-code {
            background-color: #263238;
            color: #ffffff;
            padding: 10px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            margin: 5px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚨 Dynamic Evaluation Vulnerability Demo</h1>
        
        <div class="warning">
            <strong>⚠️ WARNING:</strong> This is a deliberately vulnerable application for educational purposes only. 
            Never use eval() with user input in production code!
        </div>

        <p>This simple calculator uses PHP's <code>eval()</code> function to evaluate mathematical expressions. 
        However, this creates a serious security vulnerability.</p>

        <form method="POST">
            <div class="form-group">
                <label for="expression">Enter a mathematical expression:</label>
                <input type="text" id="expression" name="expression" 
                       placeholder="e.g., 2 + 3 * 4" 
                       value="<?php echo isset($_POST['expression']) ? htmlspecialchars($_POST['expression']) : ''; ?>">
            </div>
            <button type="submit">Calculate</button>
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['expression'])) {
            $expression = $_POST['expression'];
            
            echo "<div class='result'>";
            echo "<h3>Input: " . htmlspecialchars($expression) . "</h3>";
            
            if (!empty($expression)) {
                echo "<h3>Result:</h3>";
                
                // VULNERABLE CODE - Never do this in production!
                try {
                    // This is the dangerous line that creates the vulnerability
                    $result = eval("return $expression;");
                    echo "<p><strong>Output:</strong> " . htmlspecialchars($result) . "</p>";
                } catch (ParseError $e) {
                    echo "<p style='color: red;'><strong>Parse Error:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
                } catch (Error $e) {
                    echo "<p style='color: red;'><strong>Error:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
                } catch (Exception $e) {
                    echo "<p style='color: red;'><strong>Exception:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
                }
            }
            echo "</div>";
        }
        ?>

        <div class="examples">
            <h3>🧮 Safe Examples (Try these):</h3>
            <div class="example-code">2 + 3</div>
            <div class="example-code">10 * 5 - 3</div>
            <div class="example-code">sqrt(16)</div>
            <div class="example-code">pow(2, 3)</div>

            <h3>💀 Dangerous Examples (Shows the vulnerability):</h3>
            <div class="example-code">phpinfo()</div>
            <div class="example-code">system('whoami')</div>
            <div class="example-code">file_get_contents('/etc/passwd')</div>
            <div class="example-code">unlink('important_file.txt')</div>

            <h3>🛡️ How to Fix:</h3>
            <ul>
                <li><strong>Never use eval() with user input</strong></li>
                <li>Use proper parsing libraries for mathematical expressions</li>
                <li>Implement input validation and sanitization</li>
                <li>Use whitelisting for allowed functions/operations</li>
                <li>Consider using safer alternatives like <code>bc_math</code> functions</li>
            </ul>
        </div>

        <div style="margin-top: 20px; padding: 15px; background-color: #e8f5e8; border-radius: 4px;">
            <h3>🔒 Secure Alternative Example:</h3>
            <p>Instead of using eval(), you could:</p>
            <ul>
                <li>Parse and validate the mathematical expression</li>
                <li>Use a whitelist of allowed operations (+, -, *, /, etc.)</li>
                <li>Use libraries like <code>symfony/expression-language</code></li>
                <li>Implement a proper mathematical parser</li>
            </ul>
        </div>
    </div>
</body>
</html>
