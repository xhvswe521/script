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


$img = "<img src=\"/icons/status_circle_green.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_BLUE') {
$img = "<img src=\"/icons/status_square_blue.gif\">";
} else if ($status == 'AVAILABILITY_STATUS_RED') { 
$img = "<img src=\"/icons/status_diamond_red.gif\">";
}  else if ($status == 'AVAILABILITY_STATUS_GRAY') {
$img = "<img src=\"/icons/status_circle_black.gif\">";
} else {
$img = "<img src=\"/icons/status_square_black.gif\">";

$cmd = "ssh $var1 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /usr/local/bin/sudo /nas/home/dashboard/scripts/dashboard-crs-stat | grep -i lsnr" ;


exec($cmd, $output);

if (empty($output)) {
   $getvm = "";
} else {
   $getvm = "VM" ;
}

return $getvm;
}

?> 


</ul>

</BODY>
</HEAD>
</HTML>

