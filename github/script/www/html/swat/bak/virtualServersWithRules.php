<?php
$inUrl = $_GET["url"];
//if ( $inUrl != "" ) {
  header('Content-Type: text/plain');
//} else {
//  header('Content-Type: text/html');
//}

$includeSJVP01 = $_GET["includeSJVP01"];

$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';
$vServerWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.VirtualServer";
$location="https://$hostname/iControl/iControlPortal.cgi?";
$poolWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Pool";
$rulesWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Rule";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);
$SJVP01Str = "SJVP01";
$regExString = "\$uri matches_regex \"";
$cr = "\n";

//echo "Virtual Servers...\n";
echo $cr;

try {
  $vServerClient = new SoapClient($vServerWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $vServerList = $vServerClient->get_list();
  $poolClient = new SoapClient($poolWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $rulesClient = new SoapClient($rulesWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $poolList=$poolClient->get_list();
  $ruleList=$rulesClient->query_all_rules();

  sort( $vServerList );
  sort( $poolList );

  $allRulesArray = array();

  // Loop through the rules
  foreach ($ruleList as $rule)
  {
    // Load an array using the ruleName as the key
    $allRulesArray[$rule->rule_name] = $rule;
  }

  // Sort rules map by rule name
  ksort( $allRulesArray );

  $vServerRules = $vServerClient->get_rule($vServerList);
  $vServerDefaultPools = $vServerClient->get_default_pool_name($vServerList);

  unset($serverRules);
  $serverRules = array();
  unset($serverDefaultPools);
  $serverDefaultPools = array();

  foreach ($vServerList as $index=>$vServer)
  {
    $startStringForSJVP01 = substr($vServer,0,strlen( $SJVP01Str ));
    $startsWithSJVP01 = ($startStringForSJVP01 == $SJVP01Str); // See if Virtual Server starts with SJVP01

    $dotComLoc = strpos( $vServer, ".com" );

    // We only care about public virtual servers (right?)
    if ( $dotComLoc !== false )
    {
      $subdomainName = substr( $vServer, 0, $dotComLoc + 4 );

      if ( ! $startsWithSJVP01 || ( $startsWithSJVP01 && ( $includeSJVP01 == "true" || $includeSJVP01 == "yes" ) ))
      {
        // serverRules will contain an array of rules (key=subDomainName, value=arrayOfRulesWithPools)
        // arrayOfRulesWithPools will be (key=urlRulename [like "/buy" or "/sell/account"], value=arrayOfPools)
        // arrayOfPools will be a simple list of pool names that apply to that urlRule.
        // serverDefaultPool will be (key=subDomainName, value=default pool name).
        unset($arrayOfRulesWithPools);
        $arrayOfRulesWithPools = array();

        //echo "--------------------------------------------------\n";
        //echo "vServer Name: " . $vServer . $cr;
        //echo "subdomain Name: " . $subdomainName . $cr;
        
        $vServerRulesSubArray = $vServerRules[$index];
        $defaultPool = $vServerDefaultPools[$index];

        //echo "Default Pool: " . $defaultPool . $cr;

        if ( count($vServerRulesSubArray) > 0 )
        {
          //echo "Rules...\n";

          // Look through all rules for virtual server
          foreach ($vServerRulesSubArray as $theRule)
          {
            $aRule = $allRulesArray[$theRule->rule_name];
            $ruleName = $aRule->rule_name;
            $ruleDef = $aRule->rule_definition;

            //echo "    Rule: " . $ruleName . $cr;

            foreach ($poolList as $pool)
            {
              unset($urlRuleList);

              //echo "        Pool: " . $pool . $cr;

              $urlRuleList = getUrlRulesForPool( $aRule, $pool );
              sort($urlRuleList);

              // Only pull static domain info out for static rule set.
              if ( ( startsWith($pool, "SJVP01-STATIC") && startsWith($ruleName, "static.stubhub.com" ) ) || 
                ( !startsWith($pool, "SJVP01-STATIC") && !startsWith($ruleName, "static.stubhub.com" ) ) )
              {
                // Go through each urlRule that we found for the pool and put it into the arrayOfRulesWithPools for the subdomain (vServer)
                foreach ($urlRuleList as $urlRule)
                {
                  //echo "      urlRule: " . $urlRule . $cr;

                  // If we found the url rule, then get the pool array and 
                  if ( array_key_exists( $urlRule, $arrayOfRulesWithPools ) ) {

                    $poolArray = &$arrayOfRulesWithPools[$urlRule];

                    if ( !in_array($pool, $poolArray) )
                    {
                      $poolArray[] = $pool;
                    }

                  } else {

                    unset($poolArray);
                    $poolArray = array();
                    $poolArray[] = $pool;
                    $arrayOfRulesWithPools[$urlRule] = $poolArray;
                  }
                }
              }
            }
          }
        } else {

          //echo "No rules specified.\n";
        }

        ksort($arrayOfRulesWithPools);
        $serverRules[$subdomainName] = $arrayOfRulesWithPools;
        echo "vServer: " . $vServer . $cr;
        echo "serverDefaultPools[" . $subdomainName . "]: = " . $defaultPool . $cr .$cr;
        $serverDefaultPools[$subdomainName] = $defaultPool;
      }
      //echo $cr;
    }

    ///$vServerAddress = $vServer->address;
    //$vServerPort = $vServer->port;

    //echo "vServer Address: " . $vServerAddress . $cr;
    //echo "vServer Port: " . $vServerPort . $cr;
  }

  ksort( $serverRules );

  // If a url is passed, just return pool names list.
  if ( $inUrl != "" ) {
    
    $isSecure = false;

    // Get the protocol
    if ( startsWith( $inUrl, "https://" ) ) {

      $isSecure = true;
      $workUrl = substr($inUrl, strlen( "https://" ));

    } else {
      $workUrl = substr($inUrl, strlen( "http://" ));
    }

    echo "workUrl: " . $workUrl . $cr;

    // Find the .com reference in the url in an effort to find the subdomain name
    $findDotCom = strpos( $workUrl, ".com" );

    if ( $findDotCom !== false ) {

      $subdomainName = substr( $workUrl, 0, $findDotCom + 4 );
      echo "subdomainName: " . $subdomainName . $cr;

      $workUrl = substr( $workUrl, strlen($subdomainName) );

      echo "workUrl: " . $workUrl . $cr;

      $findQueryString = strpos( $workUrl, "?" );

      if ( $findQueryString !== false ) {
        $workUrl = substr( $workUrl, 0, $findQueryString );
      }

      echo "workUrl: " . $workUrl . $cr;

      $workUrl = addFrontSlashRemoveLastSlash( $workUrl );

      echo "workUrl: " . $workUrl . $cr;

      // OK, we think we have the domain and uri, now let's get the pool!
      $arrayOfRulesWithPools = $serverRules[$subdomainName];

      echo "count(arrayOfRulesWithPools): " . count($arrayOfRulesWithPools) . $cr;

      $pools = $arrayOfRulesWithPools[$workUrl];

      echo "count(pools): " . count($pools) . $cr;

      $retStr = "";

      if ( count($pools) > 0 )
      {
        // Loop through all the pools found for this urlRule and list them
        foreach ( $pools as $poolIndex=>$poolName )
        {
          if ( $poolIndex > 0 )
          {
            $retStr = $retStr . ", ";
          }
          
          $retStr = $retStr . $poolName;
        }
      }

      if ( strlen($retStr) == 0 ) {
        echo $serverDefaultPools[$subdomainName];
      } else {
        echo $retStr;
      }
    }


  } else {

    echo "\n\n============= RESULTS ================\n";

    foreach ( $serverRules as $subdomainName=>$arrayOfRulesWithPools )
    {
      echo "\n-----------------------------------------------\n";
      echo "SubDomain: " . $subdomainName . $cr;

      if ( count( $arrayOfRulesWithPools ) > 0 )
      {
        foreach ( $arrayOfRulesWithPools as $urlRule=>$pools )
        {
          echo "  " . $urlRule . $cr;

          // See if there are any pools for this rule
          if ( count( $pools ) > 0 )
          {
            echo "    ";

            // Loop through all the pools found for this urlRule and list them
            foreach ( $pools as $poolIndex=>$poolName )
            {
              if ( $poolIndex > 0 )
              {
                echo ",";
              }
              
              echo $poolName;
            }
            echo $cr;

          } else {
            // If no pools, output the default pool for the subdomain.
            echo "    " . $serverDefaultPools[$subdomainName] . $cr;
          }
        }
      } else {
        // If no rules, output the default pool for the subdomain.
        echo "    " . $serverDefaultPools[$subdomainName] . $cr;
      }
    }

    echo "\n\n------ Done --------\n";
  }
}
  catch (Exception $e) {
  echo "Error!<br/>\n";
}

function getUrlRulesForPool( $rule, $pool )
{
  global $regExString, $cr;

  //if ( $rule->rule_name == "jjjjjjjjjjbuy.stubhub.com-rb1009" ) {
    //$debug = true;
  //} else {
    $debug = false;
  //}

  unset($urlRuleArray); // a list of things like /sell, /blah/blah2, /1/2/3, etc.
  $urlRuleArray = array();

  // Get the pool bank from the current pool
  $poolBank = substr($pool, 0, 6);

  // Only interested in this poolBank
  if ( $poolBank == "SJVP00" || $poolBank == "SJVP01"  ) {

    // Search for "pool <pool name>".  Indicates pool name inside rule.
    $findPool = "pool " . $pool . $cr;

    if ( $debug == true ) {
      echo "findPool: " . $findPool . $cr;
    }

    $ruleDef = $rule->rule_definition;

    // Search for the pool indicator
    $foundPool = strpos( $ruleDef, $findPool );

    if ( $debug == true ) {
      echo "foundPool: " . $foundPool . $cr;
      //echo "ruleDef: " . $ruleDef . $cr;
    }

    // Find position of $findPool
    // Find backwards to "$uri matches_regex"
    // Find forward from that location to "}", that's the end of the regex line.
    // Parse out all the url subparts from there.
    while ( $foundPool !== false ) 
    {
      // Set the search string to be everything up to the foundPool string
      $searchStr = substr($ruleDef, 0, $foundPool);

      if ( $debug == true ) {
        echo "searchStr: " . $searchStr . $cr;
      }

      // Find last occurance of $regExString in string up to where we found pool
      $foundRegex = strripos( $searchStr,  $regExString );

      if ( $debug == true ) {
        echo "foundRegex: " . $foundRegex . $cr;
      }

      if ( $foundRegex !== false ) 
      {
        // After this, narrowString will contain the regex string plus a little more
        $narrowString = substr( $searchStr, $foundRegex + strlen($regExString) );

        if ( $debug == true ) {
          echo "narrowString1: " . $narrowString . $cr;
        }

        // Strip out parens? then split using or "|" bar.

        // Rule examples:
        // $uri matches_regex "^/shippingSvc/getLabel"}
        // $uri matches_regex "(jpg|bmp|gif|png|img|ico|js|css|swf|csv|txt)$"  }
        // $uri matches_regex "^(/autobulk/bulkuploaderrorreport)"}
        // $uri matches_regex "^/(contentManagement|ticketDisplay|sellSvc)"}
        // $uri matches_regex "^/(cstool)"}
        // $uri matches_regex "^(/sites/intranet)|/jmx-console|/web-console|CFIDE|/listingSearch/admin|/listingSearch/update|/agents/bulkupload/autobulkSerial.cfm"}
        // $uri matches_regex "^/(sell/donthaveticketyet|sell/enterbarcode|sell/enterbarcodecomplete|sell/plannedoutage|sell/errorpage|sell/duplicatebarcode)"}
        $foundEndingBraceAfterRegexExpression = strpos( $narrowString, "}" );

        if ( $debug == true ) {
          echo "foundEndingBraceAfterRegexExpression: " . $foundEndingBraceAfterRegexExpression . $cr;
        }

        if ( $foundEndingBraceAfterRegexExpression !== false )
        {
          // Trim off the end of the line
          $narrowString = substr( $narrowString, 0, $foundEndingBraceAfterRegexExpression );

          if ( $debug == true ) {
            echo "narrowString2: " . $narrowString . $cr;
          }

          // Now replace stuff.  This replaces each of the array elements with an empty string (removes them)
          $replaceTheseChars = array ("^","\"","$","(",")");
          $narrowString = str_replace( $replaceTheseChars, "", $narrowString);

          if ( $debug == true ) {
            echo "narrowString3: " . $narrowString . $cr;
          }

          // See if there's anything to split (explode) on (the bar | char);
          $foundBar = strpos( $narrowString, "|" );

          // If not, then just add the one pattern
          if ( $foundBar === false ) {

            $narrowString = addFrontSlashRemoveLastSlash($narrowString);

            if ( $debug == true ) {
              echo "urlRule1: " . $narrowString . $cr;
            }

            if ( ! in_array( $narrowString, $urlRuleArray ) ) {
              $urlRuleArray[] = $narrowString;
            }

          } else {

          // Otherwise, explode the string and get all the patterns
            $urlPatterns = explode("|", $narrowString);

            if ( count( $urlPatterns ) > 0 ) {

              // And add them to the rule array.
              foreach ( $urlPatterns as $aPattern ) {
              
                $aPattern = addFrontSlashRemoveLastSlash($aPattern);
                            
                if ( $debug == true ) {
                  echo "urlRule2: " . $aPattern . $cr;
                }
        
                if ( ! in_array( $aPattern, $urlRuleArray ) ) {
                  $urlRuleArray[] = $aPattern;
                }                
              }
            }
          }
        }
      }

      $foundPool = strpos( $ruleDef, $findPool, $foundPool + 1 );
    }
  }

  return $urlRuleArray;
}




function keyED($txt,$encrypt_key)
{
  $ctr='0';
  $tmp = "";
  $txt_len=strlen($txt);
  for ($i=0;$i<$txt_len;$i++)
  {
    if ($ctr==strlen($encrypt_key)) $ctr=0;
    $tmp.= substr($txt,$i,1) ^ substr($encrypt_key,$ctr,1);
    $ctr++;
  }
  return $tmp;
}

function decrypt($txt,$key)
{
  $txt = keyED($txt,$key);
  $tmp = "";
  $txt_len=strlen($txt);
  for ($i=0;$i<$txt_len;$i++)
  {
    $md5 = substr($txt,$i,1);
    $i++;
    $tmp.= (substr($txt,$i,1) ^ $md5);
  }
  return $tmp;
}

function addFrontSlashRemoveLastSlash( $txt )
{
  $retStr = trim($txt);

  if ( substr( $retStr, 0, 1 ) != "/" ) {
    $retStr = "/" . $retStr;
  }

  if ( substr( $retStr, strlen($retStr) -1 , 1) == "/" )
  {
    $retStr = substr( $retStr, 0, strlen($retStr) -1 );
  }

  return $retStr;
}

function startsWith($Haystack, $Needle){
  // Recommended version, using strpos
  return strpos($Haystack, $Needle) === 0;
}


?> 

