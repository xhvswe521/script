#!/usr/bin/perl
#----------------------------------------------------------------------------
# The contents of this file are subject to the "END USER LICENSE AGREEMENT 
# FOR F5 Software Development Kit for iControl"; you may not use this file 
# except in compliance with the License. The License is included in the 
# iControl Software Development Kit.
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is iControl Code and related documentation
# distributed by F5.
#
# The Initial Developer of the Original Code is F5 Networks,
# Inc. Seattle, WA, USA. Portions created by F5 are Copyright (C) 1996-2009 
# F5 Networks, Inc. All Rights Reserved.  iControl (TM) is a registered 
# trademark of F5 Networks, Inc.
#
# Alternatively, the contents of this file may be used under the terms
# of the GNU General Public License (the "GPL"), in which case the
# provisions of GPL are applicable instead of those above.  If you wish
# to allow use of your version of this file only under the terms of the
# GPL and not to allow others to use your version of this file under the
# License, indicate your decision by deleting the provisions above and
# replace them with the notice and other provisions required by the GPL.
# If you do not delete the provisions above, a recipient may use your
# version of this file under either the License or the GPL.
#----------------------------------------------------------------------------
#use SOAP::Lite + trace => qw(method debug);
use SOAP::Lite;
use MIME::Base64;
use HTTP::Cookies;

BEGIN { push (@INC, ".."); }
use iControlTypeCast;

#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = "10.80.66.35";
my $sUID = "dashboard";
my $sPWD = "F\@172B\@N";
my $widepool = "" ;

if ( ($sHost eq "") or ($sUID eq "") or ($sPWD eq "") )
{
  &usage();
}

sub usage()
{
  die ("Usage: gtm_mapping.pl host uid pwd \n");
}

#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials
{
  return "$sUID" => "$sPWD";
}

$GlobalLBPool = SOAP::Lite
  -> uri('urn:iControl:GlobalLB/Pool')
  -> proxy("https://$sHost/iControl/iControlPortal.cgi",
    cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
eval { $GlobalLBPool->transport->http_request->header
(
  'Authorization' => 
    'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };

$GlobalLBPoolMember = SOAP::Lite
  -> uri('urn:iControl:GlobalLB/PoolMember')
  -> proxy("https://$sHost/iControl/iControlPortal.cgi",
    cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
eval { $GlobalLBPoolMember->transport->http_request->header
(
  'Authorization' => 
    'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };

$GlobalLBWideIP = SOAP::Lite
  -> uri('urn:iControl:GlobalLB/WideIP')
  -> proxy("https://$sHost/iControl/iControlPortal.cgi",
    cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
eval { $GlobalLBWideIP->transport->http_request->header
(
  'Authorization' => 
    'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };

print "Content-type: text/html\n\n";

print << "ENDOFHTML";
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



ENDOFHTML

#----------------------------------------------------------------------------
# Main Logic
#----------------------------------------------------------------------------
 
  &getWideIPList();
  foreach $wideip (@wideipList)
  {
#    print "Wideip: $wideip\n";
     if ( $widepool ne $wideip && $widepool eq "" ) {
     $widepool = $wideip ;
     print "<ul id=lists>";
     print "<li>$wideip</li>";
     print "<ul>";
     }
     elsif ( $widepool ne $wideip && $widepool ne "" ) {
	 $widepool = $wideip ;
     	print "</ul>";
     	print "<li>$wideip</li>";
     	print "<ul>";
     } else {

	}
    # get wideip rules
    #	&getWideIPrules($wideip);
    # get wideip pool list
	&getWideIPPoolList($wideip);
  }

#----------------------------------------------------------------------------
# sub getWideIPList
#----------------------------------------------------------------------------
sub getWideIPList()
{
  $soapResponse = $GlobalLBWideIP->get_list();
  &checkResponse($soapResponse);
  @wideipList = @{$soapResponse->result};

}

#----------------------------------------------------------------------------
# sub getWideIPPoolList
#----------------------------------------------------------------------------
sub getWideIPPoolList()
{
  my ($wideIP) = @_;
  
  $soapResponse = $GlobalLBWideIP->get_wideip_pool(
    SOAP::Data->name(wide_ips => [$wideIP])
  );
  &checkResponse($soapResponse);
  @WideIPPoolAofA = @{$soapResponse->result};
  
  @WideIPPoolA = @{@WideIPPoolAofA[0]};
  foreach $WideIPPool (@WideIPPoolA)
  {
    $pool_name = $WideIPPool->{"pool_name"};
    $order = $WideIPPool->{"order"};
    $ratio = $WideIPPool->{"ratio"};
    
#    print "    Pool: $pool_name; order $order; ratio: $ratio\n";
     print "<dl>";
     print "<dt> * $pool_name </dt>";
	
	# get pool member list
    &getWideIPPoolMemberList($wideIP, $pool_name);
     print "</dl>";
  }
}

#----------------------------------------------------------------------------
# sub getWideIPrules
#----------------------------------------------------------------------------
sub getWideIPrules()
{
  my ($wideIP) = @_;
  
  $soapResponse = $GlobalLBWideIP->get_wideip_rule(
    SOAP::Data->name(wide_ips => [$wideIP])
  );
  &checkResponse($soapResponse);
  
  @WideIPruleAofA = @{$soapResponse->result};

  @WideIPruleA = @{@WideIPruleAofA[0]};
  foreach $WideIPrule (@WideIPruleA)
  {
    $rule_name = $WideIPrule->{"rule_name"};
    $priority = $WideIPrule->{"priority"};
    
   # print "  Rule: $rule_name; priority $priority;\n";
  }
}

#----------------------------------------------------------------------------
# sub getWideIPPoolMemberList
#----------------------------------------------------------------------------
sub getWideIPPoolMemberList()
{
  my ($wideIP, $pool) = (@_);

  print "Am Here :$pool";
  $soapResponse = $GlobalLBPool->get_member(
    SOAP::Data->name(pool_names => [$pool])
  );
  &checkResponse($soapResponse);
  @PoolMemberDefinitionAofA = @{$soapResponse->result};

  @PoolMemberDefinitionA = @{@PoolMemberDefinitionAofA[0]};
  foreach $PoolMemberDefinition (@PoolMemberDefinitionA)
  {
    $member = $PoolMemberDefinition->{"member"};
    $address = $member->{"address"};
    $port = $member->{"port"};
    $order = $PoolMemberDefinition->{"order"};
    
   # print "      MEMBER: ${address}:${port}; order ${order}; ";
#     print"<ol> $address </ol>";
    
	# Get pool member state
    &getWideIPPoolMemberState($wideIP, $pool, $member, $address);	

  }
}
#----------------------------------------------------------------------------
# sub getWideIPPoolMemberState
#----------------------------------------------------------------------------
sub getWideIPPoolMemberState()
{
  my ($wideIP, $pool, $memberdef, $address) = (@_);
  
  my @membersA;
  push @membersA, $memberdef;
  
  my @membersAofA;
  push @membersAofA, [@membersA];
  
  $soapResponse = $GlobalLBPoolMember->get_enabled_state(
    SOAP::Data->name(pool_names => [$pool]),
    SOAP::Data->name(members => [@membersAofA])
  );
  &checkResponse($soapResponse);
  
  @memberEnabledStateAofA = @{$soapResponse->result};
  
  @memberEnabledStateA = @{@memberEnabledStateAofA[0]};
  $memberEnabledState = @memberEnabledStateA[0];
  
  $member = $memberEnabledState->{"member"};
  $state = $memberEnabledState->{"state"};

 # print "$state\n";
   print "<dd> * $address: $state </dd>";
}

#----------------------------------------------------------------------------
# checkResponse makes sure the error isn't a SOAP error
#----------------------------------------------------------------------------
sub checkResponse()
{
  my ($soapResponse) = (@_);
  if ( $soapResponse->fault )
  {
    print $soapResponse->faultcode, " ", $soapResponse->faultstring, "\n";
    exit();
  }
}

print "</ul>";

print "</BODY>";
print "</HEAD>";
print "</HTML>";
