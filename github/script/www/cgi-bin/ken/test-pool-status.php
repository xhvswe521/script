<?php


$var1 = $argv[1];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$link1='';
$link2='';
$poolold='';


if ( $var1 == 'srwpint' ) {
	$hostname='10.80.66.35';
	}
	elseif ( $var1 == 'srwpext' ) {
	$hostname='10.80.66.30';
	}

# else {
#	$hostname='10.80.51.35';
#        }

$username='dashboard';
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
$pool_list=$client->get_list();
$poolstatus=$client->get_object_status($pool_list);
$memberlist=$client2->get_object_status($pool_list);
foreach ($pool_list as $index=>$pool)
{
$availability_status=$poolstatus[$index]->availability_status;
	$img = getgif($availability_status);
# enabled this echo
#echo "\n$img $pool:  ";

      $var2 = substr($pool, 0, 6);


      if ( $poolold !== '$pool'  &&  $poolold == '' ) {
         $poolold=$pool ;
      #   echo "$img  $pool";
       }
       elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) {
         $poolold=$pool ;
      #   echo "$img  $pool";
       }
       else {
       }

foreach ($memberlist[$index] as $member_index=>$member_value)
{

$address=$member_value->member->address;
$name=gethostbyaddr($address);
$port=$member_value->member->port;
$enabled=$member_value->object_status->enabled_status;
#$enabled=substr($enabled,15);
$status=$member_value->object_status->availability_status;
#$status=substr("$status",20);
$nodestatus = getfullstatus($status, $enabled);
#echo "<tr><td>&nbsp;</td><td>$img $address:$port</td><td>$name</td></tr>\n";
#         $var3 = substr($name, 11, 3);
#         if ( $var3 == 'SR'  ) {
#	 $hname = gethostbyaddr($name);
#         echo "<li>$img   <a href=dashboard-stubhub-info.pl?myhosts=$hname>$hname</a></li>";
#        } else {

if ( $var1 == 'srwpint' ) {
         #echo "$name>";
         #$var3 = explode('.', $name);
	 #$var4 = "10.80.81.$var3[3]";
	 #$hname=gethostbyaddr($var4);
         echo "$pool int $name $nodestatus \n";
	}
	else {
         $var3 = explode('.', $name);
	 $var4 = "10.80.81.$var3[3]";
	 $hname=gethostbyaddr($var4);
         echo "$pool ext $hname $nodestatus \n";
	}
#        }

}
}
}

catch (Exception $e) {
echo "Error!<br />";
}

function getgif($status) {
if ($status == 'AVAILABILITY_STATUS_GREEN')
{
$img = "status_circle_green";
} else if ($status == 'AVAILABILITY_STATUS_BLUE') {
$img = "status_square_blue";
} else if ($status == 'AVAILABILITY_STATUS_RED') { 
$img = "status_diamond_red";
}  else if ($status == 'AVAILABILITY_STATUS_GRAY') {
$img = "status_circle_black";
} else {
$img = "status_square_black";
}
return $img;

}

function getfullstatus($status, $enabled) {

if ($status == 'AVAILABILITY_STATUS_GREEN' && $enabled == 'ENABLED_STATUS_ENABLED')
{
$status="ONLINE_ENABLED";
} else if ($status == 'AVAILABILITY_STATUS_GREEN' && $enabled == 'ENABLED_STATUS_DISABLED') {
$status="ONLINE_DISABLED";
} else if ($status == 'AVAILABILITY_STATUS_RED' && $enabled == 'ENABLED_STATUS_DISABLED') {
$status="OFFLINE_DISABLED";
} else if ($status == 'AVAILABILITY_STATUS_RED' && $enabled == 'ENABLED_STATUS_ENABLED') {
$status="OFFLINE_ENABLED";
} else {
$status="UNKNOWN";
}
return $status;

}

?> 


