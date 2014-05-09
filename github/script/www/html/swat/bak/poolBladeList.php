<?php
header('Content-Type: text/plain'); // plain text file
$whichPool = $_GET["pool"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';

//////////////// INTERNAL BigIP /////////////
$hostnameInternal='10.80.66.35';

//////////////// EXTERNAL BigIP /////////////
$hostnameExternal='10.80.66.30';

outputForBigIP( $hostnameInternal );
outputForBigIP( $hostnameExternal );

function outputForBigIP( $hostname ) {

  $wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Pool";
  $location="https://$hostname/iControl/iControlPortal.cgi?";
  $wsdl2="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.PoolMember";

  $fp = fopen($myFile, 'r');
  $theData = fread($fp, filesize($myFile));
  fclose($fp);

  $password = decrypt($theData,$Salt);
  $poolDelimiter = ":";
  $bladeDelimiter = "~";


  try {
    $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
    $client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
    $pool_list=$client->get_list();
    $poolstatus=$client->get_object_status($pool_list);
    $memberlist=$client2->get_object_status($pool_list);

    $poolArray = array();

    foreach ($pool_list as $index=>$pool)
    {
      $poolName = str_replace( "-", "_", $pool);
      $poolName = str_replace( ".", "_", $poolName);
      $poolBank = substr($poolName, 0, 6);
      $bladeArray = array();
      $bladeList = $memberlist[$index];

      if ( $poolBank == "SRWP00" || $poolBank == "SRWP01" ) {

        foreach ($bladeList as $member_index=>$member_value)
        {
          $address=$member_value->member->address;
          $bladeName=substr(gethostbyaddr($address), 0, 12);
          $bladeArray[] = $bladeName;
        }

        sort($bladeArray);
        $poolArray[$poolName] = $bladeArray;
      }
    }

    ksort($poolArray);

    if ( $whichPool == "" ) {

        foreach ($poolArray as $theKey => $bladeArray ) 
        {
          echo $theKey . $poolDelimiter;

          $bladeCount = 0;
          foreach ($bladeArray as $bladeName ) 
          {

            if ( $bladeCount > 0 ) {
              echo $bladeDelimiter;
            }
            echo $bladeName;

            $bladeCount++;
          }
          echo "\n";
        }

    } else {
      // The pool was specified, so only give the count for that pool
      echo $poolArray[$whichPool];
    }

  }
  catch (Exception $e) {
  echo "Error!\n";
  }
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

