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

BEGIN {push (@INC, "..");}
use iControlTypeCast;

#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = $ARGV[0];
my $sPort = $ARGV[1];
my $sUID = $ARGV[2];
my $sPWD = $ARGV[3];
my $sPool = $ARGV[4];
my $sProtocol = "https";

if ( ("80" eq $sPort) or ("8080" eq $sPort) )
{
        $sProtocol = "http";
}

if ( ($sHost eq "") or ($sPort eq "") or ($sUID eq "") or ($sPWD eq "") )
{
        die ("Usage: PoolStats.pl host port uid pwd [pool_name]\n");
}

#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials
{
        return "$sUID" => "$sPWD";
}

$ITCMSystemInfo = SOAP::Lite
        -> uri('urn:iControl:ITCMSystem/SystemInfo')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");

$Pool_4 = SOAP::Lite
        -> uri('urn:iControl:ITCMLocalLB/Pool')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");

$Pool = SOAP::Lite
        -> uri('urn:iControl:LocalLB/Pool')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");

$PoolMember = SOAP::Lite
        -> uri('urn:iControl:LocalLB/PoolMember')
        -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");


# Determine product version

$version_info = &getBIGIPVersion();
if ( "9" eq $version_info->{"major"} )
{
        # Version 9.0 and above
        if ( $sPool eq "" )
        {
                &getAllPoolInfo_9();
        }
        else
        {
                &getPoolInfo_9($sPool);
        }
}
elsif ( "4" eq $version_info->{"major"} )
{
        # Version 4.x
        if ( $sPool eq "" )
        {
                &getAllPoolInfo_4();
        }
        else
        {
                &getPoolInfo_4($sPool);
        }
}
else
{
        print "Could not determine product version\n";
}


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
# getBIGIPVersion
#----------------------------------------------------------------------------
sub getBIGIPVersion()
{
        $bigip_version = "Unknown";
        $is_4x = 1;
        
        $soapResponse = $ITCMSystemInfo->get_product_info();
        if ( $soapResponse->fault )
        {
                $is_4x = 0;
                $soapResponse = $SystemInfo->get_product_information();
        }
        &checkResponse($soapResponse);

        my @ProductInfoSeq;
        if ( $is_4x == 1 )
        {
                @ProductInfoSeq = @{$soapResponse->result};
        }
        else
        {
                push @ProductInfoSeq, $soapResponse->result;
        }

        foreach $ProductInformation (@ProductInfoSeq)
        {
                $product_code = $ProductInformation->{"product_code"};
                if ( "BIG-IP" eq $product_code )
                {
                        $product_version = $ProductInformation->{"product_version"};
                        
                        # Determine if this is 9.0 or 4.x...
                        if ( $product_version =~ /9/ )
                        {
                                $bigip_version = $product_version;
                        }
                        else
                        {
                                $bigip_version = $product_version;
                                $bigip_version =~ s/BIG-IP Kernel //g;
                                $bigip_version =~ s/ Build.+$//g;
                        }
                }
        }
        
        # extract major and minor versions
        $version_major = $bigip_version;
        $version_major =~ s/\..+$//g;
        $version_minor = $bigip_version;
        $version_minor =~ s/^[0-9]\.//g;
        
        $version_info =
        {
                full => $bigip_version,
                major => $version_major,
                minor => $version_minor
        };
        
        return $version_info;
}

#----------------------------------------------------------------------------
# getAllPoolInfo_9
#----------------------------------------------------------------------------
sub getAllPoolInfo_9()
{
        $soapResponse = $Pool->get_list();
        &checkResponse($soapResponse);
        my @pool_list = @{$soapResponse->result};

        &getPoolInfo_9(@pool_list);
}

#----------------------------------------------------------------------------
# getPoolInfo_9
#----------------------------------------------------------------------------
sub getPoolInfo_9()
{
        my @pool_list = @_;

        # Get LBMethods
        $soapResponse = $Pool->get_lb_method
        (
                SOAP::Data->name(pool_names => [@pool_list])
        );
        &checkResponse($soapResponse);
        my @lb_methods = @{$soapResponse->result};

        # Get min/cur active members
        $soapResponse = $Pool->get_minimum_active_member
        (
                SOAP::Data->name(pool_names => [@pool_list])
        );
        &checkResponse($soapResponse);
        my @min_active_members = @{$soapResponse->result};

        $soapResponse = $Pool->get_active_member_count
        (
                SOAP::Data->name(pool_names => [@pool_list])
        );
        &checkResponse($soapResponse);
        my @cur_member_list = @{$soapResponse->result};

        # Get Pool Statistics
        $soapResponse = $Pool->get_statistics
        (
                SOAP::Data->name(pool_names => [@pool_list])
        );
        &checkResponse($soapResponse);
        my $pool_stats = $soapResponse->result;
        @PoolStatisticsEntryList = @{$pool_stats->{"statistics"}};

        # Get Member Statistics
        $soapResponse = $PoolMember->get_all_statistics
        (
                SOAP::Data->name(pool_names => [@pool_list])
        );
        &checkResponse($soapResponse);
        my @member_stats = @{$soapResponse->result};

        # Process Data
        $i = 0;
        foreach $pool_name (@pool_list)
        {
                print "POOL $pool_name  ";
                print "LB_METHOD @lb_methods[$i] ";
                print "MIN/CUR ACTIVE MEMBERS: @min_active_members[$i]/@cur_member_list[$i]\n";

                foreach $PoolStatisticsEntry (@PoolStatisticsEntryList)
                {
                        $poolName = $PoolStatisticsEntry->{"pool_name"};
                        if ( $poolName eq $pool_name )
                        {
                                @statistics = @{$PoolStatisticsEntry->{"statistics"}};

                                foreach $stat (@statistics)
                                {
                                        $type = $stat->{"type"};
                                        $value = $stat->{"value"};
                                        $low  = $value->{"low"};
                                        $high  = $value->{"high"};
                                        $value64 = ($high<<32)|$low;
                                        $time_stamp = $statistics->{"time_stamp"};
                                        print "|    $type : $value64\n";
                                }
                        }
                }

                $MemberStatistics = @member_stats[$i];

                @MemberStatisticsEntryList = @{$MemberStatistics->{"statistics"}};
                $MemberStatisticsTimeStamp = $MemberStatistics->{"time_stamp"};

                foreach $MemberStatisticEntry (@MemberStatisticsEntryList)
                {
                        $member = $MemberStatisticEntry->{"member"};
                        $address = $member->{"address"};
                        $port = $member->{"port"};
                        print "+-> MEMBER $address:$port\n";

                        @StatisticList = @{$MemberStatisticEntry->{"statistics"}};
                        foreach $stat (@StatisticList)
                        {
                                $type = $stat->{"type"};
                                $value = $stat->{"value"};
                                $low  = $value->{"low"};
                                $high  = $value->{"high"};
                                $value64 = ($high<<32)|$low;
                                $time_stamp = $stat->{"time_stamp"};

                                print "    |    $type : $value64\n";
                        }
                }

                $i++;
        }
}

#----------------------------------------------------------------------------
# getAllPoolInfo_4
#----------------------------------------------------------------------------
sub getAllPoolInfo_4()
{
        $soapResponse = $Pool_4->get_list();
        &checkResponse($soapResponse);
        my @pool_list = @{$soapResponse->result};

        &getPoolInfo_4(@pool_list);
}

#----------------------------------------------------------------------------
# getPoolInfo_4
#----------------------------------------------------------------------------
sub getPoolInfo_4()
{
        my @pool_list = @_;

        foreach $pool_name (@pool_list)
        {
                $soapResponse = $Pool_4->get_lb_method
                (
                        SOAP::Data->name(pool_name => $pool_name)
                );
                &checkResponse($soapResponse);
                $lb_method = $soapResponse->result;
                
                $soapResponse = $Pool_4->get_minimum_active_member
                (
                        SOAP::Data->name(pool_name => $pool_name)
                );
                &checkResponse($soapResponse);
                $min_active_members = $soapResponse->result;
                
                # Get Pool Statistics
                $soapResponse = $Pool_4->get_statistics
                (
                        SOAP::Data->name(pool_name => $pool_name)
                );
                &checkResponse($soapResponse);
                my $stats = $soapResponse->result;
                my $thruput_stats = $stats->{"thruput_stats"};
                my $bits_in = $thruput_stats->{"bits_in"};
                my $bits_out = $thruput_stats->{"bits_out"};
                my $packets_in = $thruput_stats->{"packets_in"};
                my $packets_out = $thruput_stats->{"packets_out"};
        
                my $conn_stats = $stats->{"connection_stats"};
                my $cur_conn = $conn_stats->{"current_connections"};
                my $max_conn = $conn_stats->{"maximum_connections"};
                my $total_conn = $conn_stats->{"total_connections"};

        
                # Get Member Statistics
                $soapResponse = $Pool_4->get_all_member_statistics
                (
                        SOAP::Data->name(pool_name => $pool_name)
                );
                &checkResponse($soapResponse);
                @MemberStatisticsEntryList = @{$soapResponse->result};

                # Print Results
                print "POOL $pool_name  ";
                print "LB_METHOD $lb_method ";
                print "MIN ACTIVE MEMBERS: $min_active_members\n";

                print "--> bits (in, out) ";
                print "(", $bits_in, ", ", $bits_out, ")\n";
                print "    packets (in, out) ";
                print "(", $packets_in,  ", ", $packets_out, ")\n";
                print "    connections (cur, max, tot) ";
                print "(", $cur_conn, ", ", $max_conn, ", ", $total_conn, ")\n";
                
                foreach $MemberStatisticEntry (@MemberStatisticsEntryList)
                {
                        $member = $MemberStatisticEntry->{"member_definition"};
                        $address = $member->{"address"};
                        $port = $member->{"port"};
                        print "+-> MEMBER $address:$port\n";
                        
                        $stats = $MemberStatisticEntry->{"stats"};
                        $thruput_stats = $stats->{"thruput_stats"};
                        $bits_in = $thruput_stats->{"bits_in"};
                        $bits_out = $thruput_stats->{"bits_out"};
                        $packets_in = $thruput_stats->{"packets_in"};
                        $packets_out = $thruput_stats->{"packets_out"};
        
                        $conn_stats = $stats->{"connection_stats"};
                        $cur_conn = $conn_stats->{"current_connections"};
                        $max_conn = $conn_stats->{"maximum_connections"};
                        $total_conn = $conn_stats->{"total_connections"};
        
                        print "    |    bits (in, out) ";
                        print "(", $bits_in, ", ", $bits_out, ")\n";
                        print "    packets (in, out) ";
                        print "(", $packets_in,  ", ", $packets_out, ")\n";
                        print "    connections (cur, max, tot) ";
                        print "(", $cur_conn, ", ", $max_conn, ", ", $total_conn, ")\n";
                }
        }
}


