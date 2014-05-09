#!/usr/bin/perl
#
#
# Author             : Pawan Dube 
# Date               : 11/13/2008
# Modified by        :
# Modified Date      :


use warnings;
use strict;
use Socket;
use CGI ;

my $q = new CGI;
my $myhost = $q->param('myhosts');


print "Content-type: text/html\n\n";

print << "ENDOFHTML";
<HTML>
<HEAD>
<TITLE>DashBoard</B></CENTER></TITLE>
<BODY background="/icons/page-background.png">
<body text="#808080">
<IMG SRC="/icons/stubhub.gif" width="142" height="60" align="left">
<h1 align="center" font size=1> Netops-DashBoard</center></h1>
<br>
<br>
ENDOFHTML


open(SMP, "ssh -o StrictHostKeyChecking=no sjvp01brs001.stubhub.com /opt/quest/bin/sudo /nas/home/dashboard/scripts/SystemInfo -b  |") || die "Failed: $!\n";
#open(SMP, "ssh -o StrictHostKeyChecking=no $myhost /opt/quest/bin/sudo /usr/contrib/bin/SystemInfo -b  |") || die "Failed: $!\n";
#open(SMP, "ssh -o StrictHostKeyChecking=no $myhost |") || die "Failed: $!\n";
#open(SMP, "ssh $myhost /opt/quest/bin/sudo /nas/home/dashboard/scripts/SystemInfo -b  |") || die "Failed: $!\n";

while ( <SMP> ) {
  chomp;
  my $line = $_;
  print "<br>\n";
  print "$line \n";
} # while


print "</BODY>";
print "</HEAD>";
print "</HTML>";
