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

$poolold='';
$username='dashboard';
$hostname='10.80.132.10';
$wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.VirtualServer";
$location="https://$hostname/iControl/iControlPortal.cgi?";

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
$pool_list=$client->get_list();
$poolstatus=$client->get_object_status($pool_list);
$pooldest=$client->get_destination($pool_list);
$poolname=$client->get_default_pool_name($pool_list);
$poolprofile=$client->get_persistence_profile($pool_list);
$poolrule=$client->get_rule($pool_list);



foreach ($pool_list as $index=>$pool)
{
	$pooldest1=$pooldest[$index]->address;
        $poolname1=$poolname[$index];
	$poolport=$pooldest[$index]->port;
	$availability_status=$poolstatus[$index]->availability_status;
        $img = getgif($availability_status);

	 $var2 = substr($pool, 0, 6);

      	if ( $var2 == $var1 ) {

      if ( $poolold !== '$pool'  &&  $poolold == '' ) {
         $poolold=$pool ;
         echo "<ul id=lists>";
         echo "<li>$img   <B><font color=#4863A0><I>$pool</I></font></B>";
         echo "<ul>";
       }
       elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) {
         $poolold=$pool ;
         echo "</ul>";
         echo "<li>";
         echo "<li>$img    <B><font color=#4863A0><I>$pool</I></font></B>";
         echo "<ul>";
       }
       else {
       }

	if ( $poolname1 == '') {
	$poolname1='None';
        }

echo "<li><font color=#996600><B>Destination : $pooldest1</font> </li>";
echo "<li><font color=#996600>Service Port: $poolport</font> </li>";
echo "<li><font color=#996600>Default Pool: $poolname1</font></li>";


foreach ($poolprofile[$index] as $profile_index=>$profile_value)
{
       $profile=$profile_value->profile_name;
echo "<li><font color=#996600>Default Persistence Profile : $profile</font> </li>";
} 

foreach ($poolrule[$index] as $rule_index=>$rule_value)
{
       $rule=$rule_value->rule_name;

echo "<li><font color=#996600>iRule Values: $rule</font> </li>";
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

