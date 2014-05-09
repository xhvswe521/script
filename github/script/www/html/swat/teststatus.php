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

if ( $var1 == 'SJVP00' ) {
  	 echo "<h1 align=center font size=1><img src=/icons/shared.gif></center></h1>";
	}
        elseif ( $var1 == 'SJVP01' ) {
	echo "<h1 align=center font size=1><img src=/icons/P01.gif></center></h1>";
	} else {
	echo "<h1 align=center font size=1><img src=/icons/P02.gif></center></h1>";
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

      if ( $var2 == $var1 ) {

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
$status=$member_value->object_status->availability_status;
$img = getgif($status);
#echo "<tr><td>&nbsp;</td><td>$img $address:$port</td><td>$name</td></tr>\n";
         $var3 = substr($name, 6, 2);
         if ( $var3 == 'cf' || $var3 == 'em' || $var3 == 'ft' || $var3 == 'fd' || $var3 == 'bp' || $var3 == 'il' || $var3 == 'wl' || $var3 == '-v' || $var3 == '.1' || $var3 == '.2' || $var3 == 'db' ) {
         echo "<li>Status: $status $img   <a href=dashboard-stubhub-info.pl?myhosts=$name>$name</a></li>";
        } else {
         echo "<li>Status: $status $img   <a href=dashboard-stubhub-info.pl?myhosts=$name>$name</a> <a href=http://$name/web-console target=_blank> <img src=/icons/jb-wc.gif></a></li>";
        }

}
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

?> 


</ul>

</BODY>
</HEAD>
</HTML>

