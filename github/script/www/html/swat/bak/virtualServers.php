<?php
header('Content-Type: text/plain');
$includeSJVP01 = $_GET["includeSJVP01"];

$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';
$wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.VirtualServer";
$location="https://$hostname/iControl/iControlPortal.cgi?";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);
$SJVP01Str = "SJVP01";

echo "Virtual Servers...\n";
echo "\n";

try {
  $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $vServerList = $client->get_list();
  sort($vServerList);

  $rules = $client->get_rule($vServerList);
  $defaultPools = $client->get_default_pool_name($vServerList);

  foreach ($vServerList as $index=>$vServer)
  {
    $startStringForSJVP01 = substr($vServer,0,strlen( $SJVP01Str ));
    $startsWithSJVP01 = ($startStringForSJVP01 == $SJVP01Str); // See if Virtual Server starts with SJVP01

    if ( ! $startsWithSJVP01 || ( $startsWithSJVP01 && ( $includeSJVP01 == "true" || $includeSJVP01 == "yes" ) ))
    {
      echo "--------------------------------------------------\n";
      echo "vServer Name: " . $vServer . "\n";

      $rulesSubArray = $rules[$index];
      $defaultPool = $defaultPools[$index];

      echo "Default Pool: " . $defaultPool . "\n";

      if ( count($rulesSubArray) > 0 ) {
        echo "Rules...\n";

        foreach ($rulesSubArray as $aRule)
        {
          echo "    " . $aRule->rule_name . "\n";
        }

      } else {

        echo "No rules specified.\n";
      }
        
      echo "\n";
    }

    ///$vServerAddress = $vServer->address;
    //$vServerPort = $vServer->port;

    //echo "vServer Address: " . $vServerAddress . "\n";
    //echo "vServer Port: " . $vServerPort . "\n";
  }

  echo "\n\n------ Done --------\n";
}
  catch (Exception $e) {
  echo "Error!<br/>\n";
}


function keyED($txt,$encrypt_key)
{
  $ctr='0';
  $tmp = "";
  $txt_len=strlen($txt);
  for ($i=0;$i<$txt_len;$i++)
  {
    if ($ctr==strlen($encrypt_key)) $ctr=0;
    $tmp.= substr($txt,$i,1) ^ substr($encrypt_key,$ctr,1);
    $ctr++;
  }
  return $tmp;
}

function decrypt($txt,$key)
{
  $txt = keyED($txt,$key);
  $tmp = "";
  $txt_len=strlen($txt);
  for ($i=0;$i<$txt_len;$i++)
  {
    $md5 = substr($txt,$i,1);
    $i++;
    $tmp.= (substr($txt,$i,1) ^ $md5);
  }
  return $tmp;
}

?> 

