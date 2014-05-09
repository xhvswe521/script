<HTML>
<HEAD>
<TITLE>DashBoard</TITLE>

<script type="text/javascript">
var aUL=null;
window.onload=function() {
aUL=document.getElementById('lists').getElementsByTagName('ul');
for(var i=0;i<aUL.length; i++) {
  if (aUL[i].addEventListener) { // W3C
        aUL[i].parentNode.addEventListener('click', function() {toggle(this); }, false);
    }
  else {
        aUL[i].parentNode.click=function() {toggle(this);};
    }
  aUL[i].parentNode.style.cursor='pointer';
  aUL[i].className='collapse';
  }
}

function toggle(obj) {
for(var i=0;i<aUL.length; i++) {
  aUL[i].className='collapse';
  }
var list=obj.getElementsByTagName('ul')[0];
list.className='expand';
}
</script>

<style type="text/css">
.collapse {display:none;}
.expand {display:block;}
</style>


<BODY background=/icons/page-background.png>
<body text=#808080>


<?php


$var1 = $_GET["var1"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$link1='';
$link2='';
$poolold='';



if ( $var1 == 'SRWPINT' ) {
  	 echo "<h1 align=center font size=1><img src=/icons/Internal-1.png></center></h1>";
	$hostname='10.80.66.35';
	}
	elseif ( $var1 == 'SRWPEXT' ) {
	echo "<h1 align=center font size=1><img src=/icons/External-1.png></center></h1>";
	$hostname='10.80.66.30';
	} else {
	echo "<h1 align=center font size=1><img src=/icons/Siebel.png></center></h1>";
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
         echo "<ul id=lists>";
         echo "<li><B><font color=#4863A0><I>$img  $pool</I></font></B>";
         echo "<ul>";
       }
       elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) {
         $poolold=$pool ;
         echo "</ul>";
         echo "<li>";
         echo "<li><B><font color=#4863A0><I>$img  $pool</I></font></B>";
         echo "<ul>";
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
         echo "<li>$img   <a href=dashboard-stubhub-info.pl?myhosts=$name>$name</a> </li>";
	}
	else {
         $var3 = explode('.', $name);
	 $var4 = "10.80.81.$var3[3]";
	 $hname=gethostbyaddr($var4);
         echo "<li>$img  <a href=dashboard-stubhub-info.pl?myhosts=$hname>$hname</a> </a></li>";
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


</ul>

</BODY>
</HEAD>
</HTML>

