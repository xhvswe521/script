<?php
header('Content-Type: text/plain'); // plain text file
$inIp = $_GET["ip"];

if ( strpos($inIp, "10.") !== 0 ) {

  // Have to translate from external to internal ip address first
  $subnets = explode('.', $inIp);
  $inIp = "10.80.81.$subnets[3]";
}

$hostname = gethostbyaddr($inIp);
echo $hostname;
?> 

