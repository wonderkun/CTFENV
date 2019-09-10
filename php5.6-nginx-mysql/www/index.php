<?php

$servername = "mysql";
$username = "root";
$password = "root";

function mysqliConnTest(){
    global $servername;
    global $username ;
    global $password;
    $conn = new mysqli($servername, $username, $password);
    if($conn) echo "mysqli connect success !</br>";
    else echo "mysqli connect error !</br>";
}


function pdoConnTest(){
    global $servername;
    global $username ;
    global $password;

    try {
        $conn = new PDO("mysql:host=$servername;",$username, $password);
        echo "pdo connect success!</br>"; 
    }
    catch(PDOException $e)
    {
        echo $e->getMessage();
    }
}

mysqliConnTest();
pdoConnTest();
