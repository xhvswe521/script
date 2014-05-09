#!/usr/bin/perl
#
# ip2h.pl - 19/Aug/1995
#
#  by David Efflandt <efflandt@xnet.com>
#
#  Inputs IP addresses from keyboard and outputs to screen.
#  Loops for multiple entries.
#
print "\nEnter the 4 numbers separated by periods (no spaces).\n";
print "Press [enter] key without a number to exit.\n\n";
print "Enter IP address: ";
$ip = <STDIN>;
chop($ip);
while ($ip) {
  @numbers = split(/\./, $ip);
  $ip_number = pack("C4", @numbers);
  ($name) = (gethostbyaddr($ip_number, 2))[0];
  if ($name) {
    print "The host is: $name";
  } else {
    print "This IP has no name";
  }
  print "\n\nEnter IP address: ";
  $ip = <STDIN>;
  chop($ip);
}
