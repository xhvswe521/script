#!/usr/bin/perl
#----------------------------------------------------------------------------
# The contents of this file are subject to the "END USER LICENSE AGREEMENT FOR F5
# Software Development Kit for iControl"; you may not use this file except in
# compliance with the License. The License is included in the iControl
# Software Development Kit.
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
# Inc. Seattle, WA, USA. Portions created by F5 are Copyright (C) 1996-2004 F5 Networks,
# Inc. All Rights Reserved.  iControl (TM) is a registered trademark of F5 Networks, Inc.
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

#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = $ARGV[0];
my $sPort = $ARGV[1];
my $sUID = $ARGV[2];
my $sPWD = $ARGV[3];
my $sProtocol = "https";

if ( ("80" eq $sPort) or ("8080" eq $sPort) )
{
        $sProtocol = "http";
}

if ( ($sHost eq "") or ($sPort eq "") or ($sUID eq "") or ($sPWD eq "") )
{
        die ("Usage: PoolsInRules.pl host port uid pwd\n");
}

#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials
{
        return "$sUID" => "$sPWD";
}

$Rule = SOAP::Lite
        -> uri('urn:iControl:LocalLB/Rule')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");
eval { $Rule->transport->http_request->header
(
        'Authorization' => 
                'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };

$Pool = SOAP::Lite
        -> uri('urn:iControl:LocalLB/Pool')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");
eval { $Pool->transport->http_request->header
(
        'Authorization' => 
                'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };



&getAllPoolsInRules();

#----------------------------------------------------------------------------
# checkResponse
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

#----------------------------------------------------------------------------
# getAllPoolsInRules
#----------------------------------------------------------------------------
sub getAllPoolsInRules()
{
        #print "Querying pool list...\n";
        $soapResponse = $Pool->get_list();
        &checkResponse($soapResponse);
        my @pool_list = @{$soapResponse->result};
        
        $soapResponse = $Rule->query_all_rules();
        &checkResponse($soapResponse);
        my @rule_def_list = @{$soapResponse->result};

        &getPoolsInRules(\@pool_list, \@rule_def_list);
        &getPoolsInRules2(\@pool_list, \@rule_def_list);
}

#----------------------------------------------------------------------------
# getPoolsInRules
#----------------------------------------------------------------------------
sub getPoolsInRules()
{
        my ($pool_list, $rule_def_list) = @_;

        print "=================================================\n";
        print "           Rules                    Pools\n";
        print "--------------------------    -------------------\n";

        foreach $rule_def (@$rule_def_list)
        {
                $i = 0;
                $rule_name = $rule_def->{"rule_name"};
                $rule_definition = $rule_def->{"rule_definition"};

                printf "%25s  => ", "$rule_name";

                foreach $pool (@$pool_list)
                {
                        $found = $rule_definition =~ /(pool)\s+($pool)/;
                        if ( $found )
                        {
                                if ( $i )
                                {
                                        print ", ";
                                }
                                print "$pool";
                                $i++;
                        }
                }
                
                print "\n";
        }
}

#----------------------------------------------------------------------------
# getPoolsInRules2
#----------------------------------------------------------------------------
sub getPoolsInRules2()
{
        my ($pool_list, $rule_def_list) = @_;


        print "=================================================\n";
        print "           Pools                    Rules\n";
        print "--------------------------    -------------------\n";

        foreach $pool (@$pool_list)
        {
                printf "%25s  => ", "$pool";
                $i = 0;
                foreach $rule_def (@$rule_def_list)
                {
                        $rule_name = $rule_def->{"rule_name"};
                        $rule_definition = $rule_def->{"rule_definition"};
        
                        $found = $rule_definition =~ /(pool)\s+($pool)/;
                        if ( $found )
                        {
                                if ( $i )
                                {
                                        print ", ";
                                }
                                print "$rule_name";
                                $i++;
                        }
                }
                print "\n";
        }
}
