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
<TITLE>DashBoard</TITLE>
<BODY background="/icons/page-background.png">
<body text="#808080">
ENDOFHTML


open(SMP, "ssh -o StrictHostKeyChecking=no $myhost /opt/quest/bin/sudo /nas/home/dashboard/scripts/SystemInfo -b  |") || die "Failed: $!\n";
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
