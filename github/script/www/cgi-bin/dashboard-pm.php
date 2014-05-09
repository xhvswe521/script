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
<IMG SRC=/icons/stubhub.gif width=142 height=60 align=left>
<h1 align="center" font size=1> Netops-DashBoard</center></h1>
<br>
<br>

<?php

$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

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


try {
$client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
$client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
$pool_list=$client->get_list();
$poolstatus=$client->get_object_status($pool_list);
$poolcount=$client->get_active_member_count($pool_list);
$poolmonitor=$client->get_monitor_instance($pool_list);
$poollb=$client->get_lb_method($pool_list);
$memberlist=$client2->get_object_status($pool_list);
$ratiolist=$client2->get_ratio($pool_list);
$prioritylist=$client2->get_priority($pool_list);



foreach ($pool_list as $index=>$pool)
{
#$availability_status=$poolstatus[$index]->availability_status;
#$img = getgif($availability_status);
	$count=$poolcount[$index];
        $monitor=$poolmonitor[$index]->template_name;
        $lb=$poollb[$index];

      if ( $poolold !== '$pool'  &&  $poolold == '' ) {
         $poolold=$pool ;
         echo "<ul id=lists>";
         echo "<li><B><font color=#4863A0><I>$pool </I></font></B>";
	 echo "<ol>---> Active Members Count : $count  & Load Balancing Method: $lb  </ol>";
         echo "<ul>";
       }
       elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) {
         $poolold=$pool ;
         echo "</ul>";
         echo "<li>";
         echo "<li><B><font color=#4863A0><I>$pool</I></font></B>";
	 echo "<ol>---> Active Members Count : $count  & Load Balancing Method: $lb  </ol>";
         echo "<ul>";
       }
       else {
       }

foreach ($memberlist[$index] as $member_index=>$member_value)
{
	        	   
$address=$member_value->member->address;
$name=gethostbyaddr($address);

foreach ($ratiolist[$index] as $ratio_index=>$ratio_value)
{

$ratio=$ratio_value->ratio;
$address1=$ratio_value->member->address;
$name1=gethostbyaddr($address1);

foreach ($prioritylist[$index] as $priority_index=>$priority_value)
{

$priority=$priority_value->priority;
$address2=$priority_value->member->address;
$name2=gethostbyaddr($address2);
$status=$member_value->object_status->availability_status;
$img = getgif($status);

if ( $name == $name1 && $name == $name2 ) {
echo "<li>$img   <a href=/cgi-bin/dashboard-second.pl?myhosts=$name>$name</a><B><table><tr><td bgcolor=#4863A0><font color=white> Ratio is $ratio & Priority Group is $priority</font></td></tr></table></B> </li>";
break ;
}
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
<br>
<br>

<CENTER><B>@ 2008-2010 StubHub, Inc. All rights reserved.<B><CENTER> 

</BODY>
</HEAD>
</HTML>

