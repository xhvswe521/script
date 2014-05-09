<?php
header('Content-Type: text/plain'); // plain text file
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
$poolDelimiter = ":";
$bladeDelimiter = "~";

// Decrypting Functions

try {
  unset($bladeArray);
  $bladeArray = array();

  $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
  $pool_list=$client->get_list();
  $poolstatus=$client->get_object_status($pool_list);
  $memberlist=$client2->get_object_status($pool_list);

  foreach ($pool_list as $index=>$pool)
  {
    $poolName = str_replace( "-", "_", $pool);
    $poolName = str_replace( ".", "_", $poolName);
    $poolBank = substr($poolName, 0, 6);
    $bladeList = $memberlist[$index];

    if ( $poolBank == "SJVP00" || $poolBank == "SJVP01" ) {

      foreach ($bladeList as $member_index=>$member_value)
      {
        $address=$member_value->member->address;
        $bladeName=substr(gethostbyaddr($address), 0, 12);
        if ( ! in_array( $bladeName, $bladeArray ) ) {
          $bladeArray[] = $bladeName;
        }
      }
    }
  }

  sort($bladeArray);

  $bladeCount = 0;
  echo "\n--------------- START: ALL BLADES ROLE! -------------------\n";

  foreach ($bladeArray as $bladeName ) 
  {
    if ( $bladeCount > 0 ) {
      echo $bladeDelimiter;
    }
    echo $bladeName;

    $bladeCount++;
  }
  echo "\n--------------- END: ALL BLADES ROLE! -------------------\n";
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

