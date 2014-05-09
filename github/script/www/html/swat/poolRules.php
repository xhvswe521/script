<?php
$inUrl = $_GET["url"];
if ( $inUrl != "" ) {
  header('Content-Type: text/plain');
} else {
  header('Content-Type: text/html');
}

$flat = $_GET["flat"];
$whichPool = $_GET["pool"];
$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';
$wsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Pool";
$location="https://$hostname/iControl/iControlPortal.cgi?";
$wsdl2="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.PoolMember";
$rulesWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Rule";
$vServerWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.VirtualServer";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);
$regExString = "if {\$uri matches_regex \"^";
$spaces = 26;
$setSubdomain = "set subdomain";
$stubDomain = ".stubhub.com";

try {
  $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
  $rulesClient = new SoapClient($rulesWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $pool_list=$client->get_list();
  $poolstatus=$client->get_object_status($pool_list);
  $memberlist=$client2->get_object_status($pool_list);
  $ruleList=$rulesClient->query_all_rules();

  $poolArray = array();
  $urlToPoolArray = array();

/*
  // Spit out all rules
  // Loop through the rules
  foreach ($ruleList as $ruleIndex=>$rule)
  {
    // Get the rule name and definition.  The ruleDef contains all the rule text.
    $ruleName = $rule->rule_name;
    //$ruleDef = $rule->rule_definition;

    //echo "--------------------------------------------------\n";
    //echo "Rule Name: " . $ruleName . "\n";
    //echo $ruleDef . "\n";
    //echo "\n\n";
  }
*/
  //echo "------\n";

  // Loop through all pools
  foreach ($pool_list as $index=>$pool)
  {
    // Get the pool bank from the current pool
    $poolBank = substr($pool, 0, 6);

    // Create the rule array
    $ruleArray = array();

    // Only interested in this poolBank
    if ( $poolBank == "SJVP00" || $poolBank == "SJVP01"  ) {

      // Search for "pool <pool name>".  Indicates pool name inside rule.
      $findPool = "pool " . $pool . "\n";

      // Loop through the rules
      foreach ($ruleList as $ruleIndex=>$rule)
      {
        // Get the rule name and definition.  The ruleDef contains all the rule text.
        $ruleName = $rule->rule_name;

        $foundStubHubComInRuleName = strpos($ruleName, $stubDomain);

        if ( $foundStubHubComInRuleName !== false ) {

          $subdomainName = substr( $ruleName, 0, $foundStubHubComInRuleName + strlen($stubDomain) );

          //echo "RuleName: " . $ruleName . "\n";
          $ruleDef = $rule->rule_definition;

          // Search for the pool indicator
          $foundPool = strpos( $ruleDef, $findPool );

  /*
          // Debug output
          if ( $foundPool !== false ) {

            // Look for carriage return after found pool string
            $foundCr = strpos( $ruleDef, "\n", $foundPool );

            // Get full found string on line
            $fullFoundStr = trim(substr( $ruleDef, $foundPool, $foundCr - $foundPool ));
            echo "fullFoundStr: " . $fullFoundStr . ", findPool: " . $findPool . "\n";

            // If they don't match ( like if we found SJVP01-CF_443 when we were actually searching for SJVP01-CF )
            // then try again a little further on
            if ( $fullFoundStr != $findPool ) {
              $foundPool = strpos( $ruleDef, $findPool, $foundPool + 1 );
            }
          }
  */
          // Find position of $findPool
          // Find backwards to "$uri matches_regex"
          // Find forward from that location to "}", that's the end of the regex line.
          // Parse out all the url subparts from there.
          while ( $foundPool !== false ) 
          {
            // Set the search string to be everything up to the foundPool string
            $searchStr = substr($ruleDef, 0, $foundPool);

            //echo "searchStr: " . $searchStr . "\n";

            // Find last occurance of $regExString in string up to where we found pool
            $foundRegex = strripos( $searchStr,  $regExString );

            //echo "foundRegex: " . $foundRegex . "\n";

            if ( $foundRegex !== false ) 
            {

              // After this, narrowString will contain the regex string plus a little more
              $narrowString = substr( $searchStr, $foundRegex + strlen($regExString) );

              //echo "narrowString1: " . $narrowString . "\n";


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

              //echo "foundEndingBraceAfterRegexExpression: " . $foundEndingBraceAfterRegexExpression . "\n";

              if ( $foundEndingBraceAfterRegexExpression !== false )
              {
                // Trim off the end of the line
                $narrowString = substr( $narrowString, 0, $foundEndingBraceAfterRegexExpression );

                //echo "narrowString2: " . $narrowString . "\n";

                // Now replace stuff.  This replaces each of the array elements with an empty string (removes them)
                $replaceTheseChars = array ("\"","$","(",")");
                $narrowString = str_replace( $replaceTheseChars, "", $narrowString);

                //echo "narrowString3: " . $narrowString . "\n";

                // See if there's anything to split (explode) on (the bar | char);
                $foundBar = strpos( $narrowString, "|" );

                // If not, then just add the one pattern
                if ( $foundBar === false ) {

                  if ( substr( $narrowString, 0, 1 ) != "/" ) {
                    $narrowString = "/" . $narrowString;
                  }

                  if ( ! in_array( $narrowString, $ruleArray ) ) {
                    $spacedPattern = padRightWithSpaces( trim($narrowString), $spaces );
                    $ruleArray[] = $spacedPattern . "[" . $ruleName . "]";
                    
                    if ( ! array_key_exists( $subdomainName . trim($narrowString), $urlToPoolArray ) ) {
                      $urlToPoolArray[$subdomainName . trim($narrowString)] = $pool;
                    } else {
                      $urlToPoolArray[$subdomainName . trim($narrowString)] = $urlToPoolArray[$subdomainName . trim($narrowString)] . ", " .$pool;
                    }
                  }

                } else {

                // Otherwise, explode the string and get all the patterns
                  $urlPatterns = explode("|", $narrowString);

                  if ( count( $urlPatterns ) > 0 ) {

                    // And add them to the rule array.
                    foreach ( $urlPatterns as $aPattern ) {
                    
                      // If it doesn't start with slash, then add it
                      if ( substr( $aPattern, 0, 1 ) != "/" ) {
                        $aPattern = "/" . $aPattern;
                      }

                      if ( ! in_array( $aPattern, $ruleArray ) ) {
                        $spacedPattern = padRightWithSpaces( trim($aPattern), $spaces );
                        $ruleArray[] = $spacedPattern . "[" . $ruleName . "]";

                        if ( ! array_key_exists( $subdomainName . trim($narrowString), $urlToPoolArray ) ) {
                          $urlToPoolArray[$subdomainName . trim($aPattern)] = $pool;
                        } else {
                          $urlToPoolArray[$subdomainName . trim($aPattern)] = $urlToPoolArray[$subdomainName . trim($aPattern)] . ", " .$pool;
                        }
                      }
                    }
                  }
                }
              }
            }

            $foundPool = strpos( $ruleDef, $findPool, $foundPool + 1 );
          }
        }
      }

      sort( $ruleArray );
      $poolArray[$pool] = $ruleArray;
    }
  }

  ksort($poolArray);
  ksort($urlToPoolArray);

  if ( $whichPool == "" ) {

    if ( $inUrl == "" ) {

      echo "<html><head><title>Pools and Rules</title></head><br/>\n";
      echo "<body><font style='font-family:courier new;'><br/>\n";
      echo "************************************************************<br/>\n";
      echo "** List of Pools with their context rules.<br/>\n";
      echo "** This list is generated dynamically using php soap calls<br/>\n";
      echo "** to the BigIP load balancer.<br/>\n";
      echo "**<br/>\n";
      echo "** Format:<br/>\n";
      echo "** -------- &lt;Pool Name&gt; --------<br/>\n";
      echo "** &lt;context rule&gt; [&lt;rule file&gt;]<br/>\n";
      echo "** &lt;context rule&gt; [&lt;rule file&gt;]<br/>\n";
      echo "** ..<br/>\n";
      echo "************************************************************<br/>\n";

      foreach ($poolArray as $theKey => $ruleArray ) 
      {
        if ( count( $ruleArray ) > 0 ) {
          echo "<br/>\n----------------------$theKey------------------------<br/>\n";
          //echo $theKey . ":\n\n";

          foreach ($ruleArray as $aRule ) 
          {
            echo $aRule . "<br/>\n";
          }
        }
      }

      echo "</font></body><br/>\n";
      echo "</html><br/>\n";

    } else {

      foreach ($urlToPoolArray as $theKey => $poolList ) 
      {
        echo "theKey: " . $theKey . "\n";
        echo "theUrl: " . $inUrl . "\n";
        echo "\n";
        if ( $theKey == $inUrl ) {
          echo "*********************\n";
          echo $poolList;
          echo "*********************\n";
        }
      }

    }

  } else {
    // The pool was specified, so only give the count for that pool
    echo $poolArray[$whichPool];
  }
}
  catch (Exception $e) {
  echo "Error!<br/>\n";
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

function padRightWithSpaces( $theString, $numSpaces )
{
  $lenTheString = strlen( $theString );
  $retStr = $theString;

  if ( $numSpaces > $lenTheString ) {
    $retStr = $retStr . str_repeat("&nbsp;", $numSpaces - $lenTheString );
  } else {
    $retStr = $retStr . "&nbsp;";
  }

  return $retStr;
}


function poolNameHasSuffix($txt,$key)
{
  return $tmp;
}

?> 

