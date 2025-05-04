<?php
function prinTable($result, $headers) {
        // Calculate the maximum length of each column for padding
        $maxlengths = array_map('strlen', $headers);

        // This will store all rows for later display
        $rows = [];

        // Loop through the result and build the rows and calculate max lengths for padding
        while ($row = $result->fetch_assoc()) {
                $values = array_values($row);
                $rows[] = $values;
                foreach ($values as $index => $value) {
                        $len = strlen($value);
                        if ($len > $maxlengths[$index]) {
                                $maxlengths[$index] = $len;
                        }
                }
        }

        // Prepare the table border using the calculated max lengths for each column
        $border = "+";
        foreach ($maxlengths as $length) {
                $border .= str_repeat("-", $length + 2) . "+";
        }

        // Print the table headers
        echo "$border\n|";
        foreach ($headers as $index => $header) {
                echo " " . str_pad($header, $maxlengths[$index]) . " |";
        }
        echo "\n$border\n";

        // Print the table rows
        foreach ($rows as $row) {
                echo "|";
                foreach ($row as $index => $cell) {
                        echo " " . str_pad($cell, $maxlengths[$index]) . " |";
                }
                echo "\n";
        }
        echo "$border\n";
}

function prompt($message) {
        echo $message;
        $input = trim(fgets(STDIN));
        return $input;
}

$host = prompt("Enter SQL host: ");
$user = prompt("Enter SQL username: ");
$pass = prompt("Enter SQL password: ");
if (empty($pass)) {
        $pass = null;
}

echo "Connecting to the SQL server...\n";
$conn = new mysqli($host, $user, $pass);
if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully.\n";

function listDatabases($conn) {
        $result = $conn->query("SHOW DATABASES");
        if ($result->num_rows > 0) {
                echo "Databases:\n";
                $headers = ['Database'];
                prinTable($result, $headers);  // Pass the headers here to format the table
        } else {
                echo "No databases found.\n";
        }
}

function listTables($conn, $db) {
        $conn->select_db($db);
        $result = $conn->query("SHOW TABLES");
        if ($result->num_rows > 0) {
                echo "Tables in database '$db':\n";
                $headers = ['Tables_in_' . $db];
                prinTable($result, $headers);  // Print tables using the correct headers
        } else if (!$result) {
                echo "Error: " . $conn->error . "\n";
        } else {
                echo "No tables found in database '$db'.\n";
        }
}

function listRows($conn, $db, $table) {
        $conn->select_db($db);
        $result = $conn->query("SELECT * FROM $table");
        if ($result->num_rows > 0) {
                echo "Rows in table '$table':\n";
                $headers = array_keys($result->fetch_assoc());  // Fetch headers from the first row
                $result->data_seek(0);  // Reset the result pointer to the first row
                prinTable($result, $headers);
                prompt("Press Enter to continue...");
        } else {
                echo "No rows found in table '$table'.\n";
        }
}

while (true) {
    listDatabases($conn);
    $db = prompt("Enter database name (or 'exit' to quit): ");
    if ($db === 'exit') {
        break;
    } else if (!preg_match('/^[a-zA-Z0-9_]+$/', $db)) {
        echo "Invalid database name. Only alphanumeric characters and underscores are allowed.\n";
        continue;
    } else if (empty($db)) {
        echo "Database name cannot be empty.\n";
        continue;
    }
    if (!$conn->select_db($db)) {
        echo "Database '$db' does not exist.\n";
        continue;
    }
    listTables($conn, $db);
    $table = prompt("Enter table name (or 'exit' to quit): ");
    if ($table === 'exit') {
        break;
    } else if (empty($table)) {
        echo "Table name cannot be empty.\n";
        continue;
    }
    listRows($conn, $db, $table);  // Use the correct function to list rows
}
$conn->close();
echo "Connection closed.\n";
// by 3LEv4t0r
?>