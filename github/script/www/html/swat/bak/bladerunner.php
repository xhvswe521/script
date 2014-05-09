<?php
header('Content-Type: text/plain'); // plain text file
//$var1 = $_GET["var1"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';

$rulesWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Rule";
$wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Pool";
$location="https://$hostname/iControl/iControlPortal.cgi?";
$wsdl2="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.PoolMember";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);

// Decrypting Functions

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

try {
	$client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
	$client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
	$rulesClient = new SoapClient($rulesWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
	$pool_list=$client->get_list();
	$poolstatus=$client->get_object_status($pool_list);
	$memberlist=$client2->get_object_status($pool_list);

  $resultsArray = array();

	foreach ($pool_list as $index=>$pool)
	{
		$availability_status=$poolstatus[$index]->availability_status;

    $bladeList = $memberlist[$index];
    $name=gethostbyaddr($bladeList[0]->member->address);
    $namePrefix = substr($name, 0, 4);
    $bladePrefix = substr($name, 0, 9);
    $bladeCount = count($bladeList);

    if (!array_key_exists( $bladePrefix, $resultsArray) && $namePrefix == "sjvp" ) {
      $resultsArray[$bladePrefix] = $bladeCount;
    }
	}

  foreach ($resultsArray as $theKey => $theValue )
  {
    echo $theKey . "\n";
  }

}
catch (Exception $e) {
echo "Error!\n";
}
?> 

