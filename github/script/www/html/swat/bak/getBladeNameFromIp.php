<?php
header('Content-Type: text/plain'); // plain text file
$inIp = $_GET["ip"];

$hostname = gethostbyaddr($inIp);
$firstPart = substr( $hostname, 0, 6);

if ( $firstPart == "sjvp01" || $firstPart == "sjvp00" ) {
  $hostname = substr( $hostname, 0, 12 );
}

echo $hostname;

?> 

