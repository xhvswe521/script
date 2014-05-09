<?php


$var1 = $argv[1];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$link1='';
$link2='';
$poolold='';



if ( $var1 == 'SRWPINT' ) {
	$hostname='10.80.66.35';
	}
	elseif ( $var1 == 'SRWPEXT' ) {
	$hostname='10.80.66.30';
	} else {
	$hostname='10.80.51.35';
        }

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
#echo "<tr><td>$img $pool</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n";

      $var2 = substr($pool, 0, 6);


      if ( $poolold !== '$pool'  &&  $poolold == '' ) {
         $poolold=$pool ;
         echo "$img  $pool";
       }
       elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) {
         $poolold=$pool ;
         echo "$img  $pool";
       }
       else {
       }

foreach ($memberlist[$index] as $member_index=>$member_value)
{

$address=$member_value->member->address;
$name=gethostbyaddr($address);
$port=$member_value->member->port;
$enabled=$member_value->object_status->enabled_status;
$status=$member_value->object_status->availability_status;
$img = getgiff($status, $enabled);
#echo "<tr><td>&nbsp;</td><td>$img $address:$port</td><td>$name</td></tr>\n";
#         $var3 = substr($name, 11, 3);
#         if ( $var3 == 'SR'  ) {
#	 $hname = gethostbyaddr($name);
#         echo "<li>$img   <a href=dashboard-stubhub-info.pl?myhosts=$hname>$hname</a></li>";
#        } else {
if ( $var1 == 'SRWPINT' || $var1 == 'SBL' ) {
         echo "$name>";
	}
	else {
         $var3 = explode('.', $name);
	 $var4 = "10.80.81.$var3[3]";
	 $hname=gethostbyaddr($var4);
         echo "$hname";
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
$img = "<img src=\"/icons/status_circle_green.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_BLUE') {
$img = "<img src=\"/icons/status_square_blue.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_RED') { 
$img = "<img src=\"/icons/status_diamond_red.gif\">";
}  else if ($status == 'AVAILABILITY_STATUS_GRAY') {
$img = "<img src=\"/icons/status_circle_black.gif\">";
} else {
$img = "<img src=\"/icons/status_square_black.gif\">";
}
return $img;

}

function getgiff($status, $enabled) {

if ($status == 'AVAILABILITY_STATUS_GREEN' && $enabled == 'ENABLED_STATUS_ENABLED')
{
$img = "<img src=\"/icons/green-avail-enb.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_GREEN' && $enabled == 'ENABLED_STATUS_DISABLED') {
$img = "<img src=\"/icons/black-avail-dis.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_RED' && $enabled == 'ENABLED_STATUS_DISABLED') {
$img = "<img src=\"/icons/black-off-dis.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_RED' && $enabled == 'ENABLED_STATUS_ENABLED') {
$img = "<img src=\"/icons/red-off-enb.gif\">";
} else {
$img = "<img src=\"/icons/red-off-enb.gif\">";
}
return $img;

}

?> 


