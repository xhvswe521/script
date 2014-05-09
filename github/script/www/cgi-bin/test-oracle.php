<?php

#$cmd = 'ssh srwp01abx002 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /sbin/lspci | grep SVGA' ;
$cmd = 'ssh pdube@srwp01dbs001 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /usr/local/bin/sudo /nas/home/dashboard/scripts/dashboard-crs-stat | grep -i lsnr | grep -i srwp01dbs001 | grep -i offline' ; 

#$last = system('ssh 10.80.21.10 -o StrictHostKeyChecking=no -o ConnectTimeout=1 /sbin/lspci | grep SVGA', $retval);
exec($cmd, $output);

#print_r($output);
var_dump($output);

if (empty($output)) {
   echo "Am Empty";
}

#if (in_array(array('ONLINE'), $output)) {
#   echo "Am  Alive" ;
#}
#if (in_array('OFFLINE', $output, true)) {
#   echo "Am a Dead Meat" ;
#}

?>

