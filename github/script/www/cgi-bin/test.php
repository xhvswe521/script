<?php

$cmd = 'ssh srwp01brs001 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /sbin/lspci | grep SVGA' ;


#$last = system('ssh 10.80.21.10 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /sbin/lspci | grep SVGA', $retval);
exec($cmd, $output);

print_r($output);

if (empty($output)) {
   echo "Am Empty";
}
elseif (in_array("SVGA", $output)) {
   echo "Am a VM" ;
 } else {
   echo "Am a Physical" ;
}


#if ($last == 'SVGA') {
#  $getvm = "This is a VM";
#} else {
#  $getvm = "This is a Physical" ;
#  }

#echo "$getvm" ;
?>

