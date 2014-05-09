#!/usr/bin/perl
#
#
# Author             : Pawan Dube 
# Date               : 12/23/2008
# Modified by        : 
# Date               : 



use warnings;
use strict;
use Socket;
use Net::Ping;


my $host1 = "";
my $host2 = "";
my $p = Net::Ping->new();
my $ip1 = "";
my $hostip1 = "";
my $hostname1 = "";
my $hostname2 = "";


# HTMP Page Display

print "Content-type: text/html\n\n";

print "<HTML>";
print "<HEAD>";
print "<TITLE>DashBoard</TITLE>";

print <<ENDOFHTML;
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


ENDOFHTML

print "<BODY background=/icons/page-background.png>";
print "<body text=#808080>";
print "<IMG SRC=/icons/stubhub.gif width=142 height=60 align=left>";
print "<h1 align=center font size=1>Netops-DashBoard</center></h1>";
print "<br>";
print "<br>";

&pingResult("sjvp01lcg0");                  
&pingResult("sjvp01brp0");                  
&pingResult("sjvp01mlb0");                  

sub pingResult {
              my $host2 = shift; 
       if ( $host2 eq "sjvp01lcg0" ) {
		 $a = 01;
 		 print "<ul id=lists>";	  
        	 print "<li><B><font color=#4863A0><I>GATHERERS</I></font></B>";
                 print "<ul>";
        }

       if ( $host2 eq "sjvp01brp0" ) {
		 $a = 01;
                 print "</ul>";
                 print "<li>";
        	 print "<li><B><font color=#4863A0><I>BROKERS</I></font></B>";
                 print "<ul>";
        }

       if ( $host2 eq "sjvp01mlb0" ) {
		 $a = 01;
                 print "</ul>";
                 print "<li>";
        	 print "<li><B><font color=#4863A0><I>MLB BROKERS</I></font></B>";
                 print "<ul>";
        }

while ($a <= 50)
{

       if ( $a <= 9 ) {
                      $b = 0;
                      $host1 = "$host2$b";
            } else {
                      $host1 = "$host2";
         }

        my $hosts = "$host1$a.stubhub.com";
	$a++;
	if ($p->ping($hosts)) {
	$hostname1 = $hosts;
	$ip1 = gethostbyname($hostname1) || die "error - gethostbyname: $!\n\n";
	$hostip1 = inet_ntoa($ip1) || die "error - inet_ntoa: $!\n\n";
	$hostname2 = gethostbyaddr(inet_aton($hostip1),AF_INET) || die "error - inet_aton: $!\n\n";
	if ( $hostname1 eq $hostname2 ) {
        print "<li><a href=cgi-bin/dashboard-second.pl?myhosts=$hostname1>$hostname1</a></li>";
        } 
      }
    }
  }


print "</ul>";

print "</BODY>";
print "</HEAD>";
print "</HTML>";

