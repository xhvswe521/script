<?php
header('Content-Type: text/plain'); // plain text file

//////////////// INTERNAL BigIP /////////////
$hostnameInternal='10.80.66.35';

//////////////// EXTERNAL BigIP /////////////
$hostnameExternal='10.80.66.30';

outputForBigIP( $hostnameInternal );
outputForBigIP( $hostnameExternal );

function outputForBigIP( $hostname ) {

  //////////////// INTERNAL BigIP /////////////
  $hostnameInternal='10.80.66.35';

  //////////////// EXTERNAL BigIP /////////////
  $hostnameExternal='10.80.66.30';

  $whichPool = $_GET["pool"];
  $Salt = "sa1";
  $myFile = "/var/www/cgi-bin/file.php";
  $username='dashboard';
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

      if ( $hostname == "$hostnameInternal" ) {
        $poolName = "I_" . $poolName;
      } else {
        $poolName = "X_" . $poolName;
      }

      $bladeArray = array();
      $bladeList = $memberlist[$index];

      if ( $poolBank == "SRWP00" || $poolBank == "SRWP01" || $poolBank == "SJVP00" || $poolBank == "SJVP01" ) {

        foreach ($bladeList as $member_index=>$member_value)
        {
          $address=$member_value->member->address;

          if ( $hostname == "$hostnameInternal" ) {
            //$bladeName=substr(gethostbyaddr($address), 0, 12);
            $bladeName=gethostbyaddr($address);
          } else {

            // Have to translate from external to internal ip address first
            $subnets = explode('.', $address);
            $internalIp = "10.80.81.$subnets[3]";
            //$bladeName=substr(gethostbyaddr($internalIp), 0, 12);
            $bladeName=gethostbyaddr($internalIp);
          }

          // If the blade hostname hasn't resolved by now, throw it away.
          if ( substr($bladeName,0,3) != "10." ) {
            $bladeArray[] = $bladeName;
          }
        }

        sort($bladeArray);
        $poolArray[$poolName] = $bladeArray;
      }
    }

    ksort($poolArray);

    if ( $whichPool == "" ) {

        if ( $hostname == "$hostnameInternal" ) {
          echo "-----_Internal_Pools_-----" . $poolDelimiter . "DUMMY" . $bladeDelimiter . "DUMMY\n";
        } else {
          echo "-----_External_Pools_-----" . $poolDelimiter . "DUMMY" . $bladeDelimiter . "DUMMY\n";
        }

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

