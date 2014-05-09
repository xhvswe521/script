<?php
header('Content-Type: text/plain'); // plain text file
$whichPool = $_GET["pool"];
$capFileInd = $_GET["capFile"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';
$wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Pool";
$location="https://$hostname/iControl/iControlPortal.cgi?";
$wsdl2="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.PoolMember";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);

// Decrypting Functions

try {
  $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
  $pool_list=$client->get_list();
  $poolstatus=$client->get_object_status($pool_list);
  $memberlist=$client2->get_object_status($pool_list);

  $poolBladesArray = array();
  $capFileArray = array();

  $capFileStarter = "";
  $capFileSuffix = "";
  $roleDelimiter = "@";
  $bladeDelimiter = "_";

  foreach ($pool_list as $index=>$pool)
  {
    $availability_status=$poolstatus[$index]->availability_status;
    $bladeList = $memberlist[$index];
    $name=gethostbyaddr($bladeList[0]->member->address);
    $namePrefix = substr($name, 0, 6);
    $bladePrefix = strtoupper(substr($name, 6, 3));
    $bladeCount = count($bladeList);

    if ( $namePrefix == "sjvp01" ) {

      //role :abi,  "sjvp01abi003", "sjvp01abi004"
      $capFileStarter = "role:" . strtolower($bladePrefix) . $roleDelimiter;

      $bladeNums="";
      $bladeCount=0;
      $bladeNums = array();

      foreach ($bladeList as $member_index=>$member_value)
      {
        $address=$member_value->member->address;
        $bladeName=gethostbyaddr($address);
        $port=$member_value->member->port;
        $status=$member_value->object_status->availability_status;
        $bladeNums[$bladeCount] = substr($bladeName, 9, 3);
        if ( $bladeCount > 0 ) {
          $capFileSuffix = $capFileSuffix . $bladeDelimiter;
        }
        $capFileSuffix = $capFileSuffix . "\"" . substr($bladeName, 0, 12) . "\"";
        $bladeCount++;
      }

      sort($bladeNums);
      $bladeNumStr = "";
      $bladeCount=0;
      foreach ($bladeNums as $theBladeNum ) {
        if ( $bladeCount > 0 ) {
          $bladeNumStr = $bladeNumStr . $bladeDelimiter;
        }
        $bladeNumStr = $bladeNumStr . $theBladeNum;
        $bladeCount++;
      }

      if (!array_key_exists( $bladePrefix, $poolBladesArray) ) {
        $poolBladesArray[$bladePrefix] = $bladeNumStr;
        $capFileArray[$bladePrefix] = $capFileStarter . $capFileSuffix;
      } else {
        $poolBladesArray[$bladePrefix] = $poolBladesArray[$bladePrefix] . $bladeDelimiter . $bladeNumStr;
        $capFileArray[$bladePrefix] = $capFileArray[$bladePrefix] . $bladeDelimiter . $capFileSuffix;
      }
    }
  }


  if ( $whichPool == "" ) {

    if ( $capFileInd == "true" )
    {
      ksort($capFileArray);

      foreach ($capFileArray as $theKey => $theValue )
      {
        echo $theValue . "\n";
      }

    } else {

      ksort($poolBladesArray);

      foreach ($poolBladesArray as $theKey => $theValue )
      {
        echo $theKey . ":" . $theValue . "\n";
      }
    }
  } else {
    // The pool was specified, so only give the count for that pool
    echo $poolBladesArray[$whichPool];
  }

}
catch (Exception $e) {
echo "Error!\n";
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

