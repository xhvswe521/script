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
$SWord = $_GET["SWord"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$link1='';
$link2='';
$poolold='';

if ( $var1 == 'SRWPINT' ) {
	echo "<h1 align=center font size=1><img src=/icons/Internal-new.png></center></h1>";
	$hostname='10.80.66.35';
}
elseif ( $var1 == 'SRWPEXT' ) {
	echo "<h1 align=center font size=1><img src=/icons/External-new.png></center></h1>";
	$hostname='10.80.66.31';
}
elseif ( $var1 == 'HOSTING' ) {
	echo "<h1 align=center font size=1><img src=/icons/Hosting-new.png></center></h1>";
	$hostname='10.80.66.62';
} else {
	echo "<h1 align=center font size=1><img src=/icons/Siebel-new.png></center></h1>";
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

function get_cap_status($name){
	$config="/nas/utl/presidio/capconfig";
	$var0 = explode('.', $name);
	$shortname=$var0[0];
	$result=`egrep "^server \"$shortname" /nas/utl/presidio/capconfig/role*.rb `;  
	if($result==""){
		return "Not defined in CAP";
	}
	$role=substr($shortname,6,3);
	$poola=$role.'([0-9][0-9])?a,';
	$poolb=$role.'([0-9][0-9])?b,';
	$prodc=$role.'06';
#echo $poola." ".$poolb." ",$result;
	if(ereg($poola,$result)){
		return "Pool A";
	}
	elseif(ereg($poolb,$result)){ 
		return "Pool B";
	}  
	elseif(ereg($prodc,$result)){ 
		return "ProdC";
	}  
	else{
		return "unknown pool status";
	}
}
try {
	$client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
	$client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
	$pool_list=$client->get_list();
#var_dump($pool_list);
#sort($pool_list);
	$poolstatus=$client->get_object_status($pool_list);
#var_dump($poolstatus);
	$memberlist=$client2->get_object_status($pool_list);
#var_dump($client->get_object_status($pool_list));
#var_dump($client->get_active_member_count($pool_list));
#var_dump ( $client->__getFunctions () );
#var_dump ( $client2->__getFunctions () );
	$active_numbers=$client->get_active_member_count($pool_list);
	function SortByAvail($a,$b){
		#error_log("fuck");
		#var_dump($GLOBALS["active_numbers"]);
		global $active_numbers;
		global $memberlist;
		$total_number_a=0;
		#foreach ($GLOBALS["memberlist[$a]"] as $member_index=>$member_value)
		foreach ($memberlist[$a] as $member_index=>$member_value)
		{
			$total_number_a++;
		} 
		$total_number_b=0;
		foreach ($memberlist[$b] as $member_index=>$member_value)
		{
			$total_number_b++;
		}
		return  ($active_numbers[$a]/$total_number_a) <= ($active_numbers[$b]/$total_number_b) ? -1 : 1;

	}
	uksort($pool_list,'SortByAvail');
	#var_dump($pool_list);

	foreach ($pool_list as $index=>$pool)
	{
		$availability_status=$poolstatus[$index]->availability_status;
		$img = getgif($availability_status);

	//	$var2 = substr($pool, 0, 6);

	$total_number=0;

	
	//sort($memberlist[$index]);
//		$check=stristr($pool,$SWord);
		if($SWord != null)
		{
		if(strlen(stristr($pool,$SWord)) == false)continue;
		}	

	foreach ($memberlist[$index] as $member_index=>$member_value)
	{
		$total_number++;
	} 

	if ( $poolold !== '$pool'  &&  $poolold == '' ) 
	{
		$poolold=$pool ;
		
		echo "<ul id=lists>";
		if($active_numbers[$index]/$total_number <= 0.4) 
		{
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#CC0000>( $active_numbers[$index] / $total_number ) </font></B>";
		}
		elseif(($active_numbers[$index]/$total_number <= 0.8)&&($active_numbers[$index]/$total_number > 0.4))			{
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#FFA500>( $active_numbers[$index] / $total_number ) </font></B>";
		}
		else
		{
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#4863A0>( $active_numbers[$index] / $total_number ) </font></B>";
		}
			echo "<ul>";
	}
	elseif ( $poolold !== '$pool'  &&  $poolold !== '' ) 
	{
		$poolold=$pool ;
		echo "</ul>";
		echo "<li>";

		if($active_numbers[$index]/$total_number <= 0.3) {
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#CC0000>( $active_numbers[$index] / $total_number ) </font></B>";
		}elseif(($active_numbers[$index]/$total_number <= 0.8)&&($active_numbers[$index]/$total_number > 0.3)){
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#FFA500>( $active_numbers[$index] / $total_number ) </font></B>";
		}else {
			echo "<li><B><font color=#4863A0><I>$img  $pool </font><font color=#4863A0>( $active_numbers[$index] / $total_number ) </font></B>";
		}

		echo "<ul>";
	}
//	else
//	{}

#var_dump($memberlist[$index]);

	//create array name=>adress
	$name_addr = array();
	foreach($memberlist[$index] as $member_index=>$member_value)
	{
		$address=$member_value->member->address;
		$enabled=$member_value->object_status->enabled_status;
		$status=$member_value->object_status->availability_status;
		$name=gethostbyaddr($address);
		if( $var1 == 'SRWPEXT' )
		{
			$var3 = explode('.', $name);
			$var4 = "10.80.81.$var3[3]";
			$hname=gethostbyaddr($var4);
			$name_addr[$hname][0] = $address;
			$name_addr[$hname][1] = $enabled;
			$name_addr[$hname][2] = $status;

		}
		else
		{	
			$name_addr[$name][0] = $address;
			$name_addr[$name][1] = $enabled;
			$name_addr[$name][2] = $status;
		}	
	}
	ksort($name_addr);
#	print_r($name_addr);

	foreach($name_addr as $key=>$value)
	{
		$name = $key;
		$enabled = $value[1]; 
		$status = $value[2];			
		$img = getgiff($status, $enabled);

		//		echo $name;
//		echo "<ul id=host_lists>";
		if ($name == "")
		{echo "<li>$img  <a href=dashboard-stubhub-info.pl?myhosts=$hname>$hname </a></li>";}
		else
		{
			$cap_status=get_cap_status($name);
			echo "<li>$img  <a href=dashboard-stubhub-info.pl?myhosts=$name>$name ($cap_status)</a></li>";
		}
//		echo "</ul>";

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

