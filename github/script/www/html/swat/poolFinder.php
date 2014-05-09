<?php
header('Content-Type: text/plain'); // plain text file
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

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);
$poolDelimiter = ":";
$bladeDelimiter = "~";
$regExString = "uri matches_regex";

try {
  $client = new SoapClient($wsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $client2 = new SoapClient($wsdl2,array('location'=>$location,'login'=>$username,'password'=>$password));
  $rulesClient = new SoapClient($rulesWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $pool_list=$client->get_list();
  $poolstatus=$client->get_object_status($pool_list);
  $memberlist=$client2->get_object_status($pool_list);
  $ruleList=$rulesClient->query_all_rules();

  $poolArray = array();

  // Loop through the rules
  foreach ($ruleList as $ruleIndex=>$rule)
  {
    // Get the rule name and definition.  The ruleDef contains all the rule text.
    $ruleName = $rule->rule_name;
    $ruleDef = $rule->rule_definition;

    echo "\n---------\n";
    echo $ruleDef;
  }

/*
  // Loop through all pools
  foreach ($pool_list as $index=>$pool)
  {
    // Get the pool bank from the current pool
    $poolBank = substr($pool, 0, 6);

    // Create the rule array
    $ruleArray = array();

    // Only interested in this poolBank
    if ( $poolBank == "SJVP01" ) {

      // Search for "pool <pool name>".  Indicates pool name inside rule.
      $findPool = "pool " . $pool;

      // Loop through the rules
      foreach ($ruleList as $ruleIndex=>$rule)
      {
        // Get the rule name and definition.  The ruleDef contains all the rule text.
        $ruleName = $rule->rule_name;
        $ruleDef = $rule->rule_definition;

        // Search for the pool indicator
        $foundPool = strpos( $ruleDef, $findPool );

        // Debug output
        if ( $foundPool !== false ) {
          echo "------------------------" . $pool . "------------------------\n";
        }

        // Find position of $findPool
        // Find backwards to "$uri matches_regex"
        // Find forward from that location to "}", that's the end of the regex line.
        // Parse out all the url subparts from there.
        while ( $foundPool !== false ) {

          // Set the search string to be everything up to the foundPool string
          $searchStr = substr($ruleDef, 0, $foundPool);

          // Find last occurance of $regExString in string up to where we found pool
          $foundRegex = strripos( $searchStr,  $regExString );

          if ( $foundRegex !== false ) {

            // After this, narrowString will contain the regex string plus a little more
            $narrowString = substr( $searchStr, $foundRegex + strlen($regExString) );

            // 


          }

          $foundPool = strpos( $ruleDef, $findPool, $foundPool + 1 );

        }
      }



      $poolArray[$pool] = $ruleArray;
    }
  }

  ksort($poolArray);

  


  if ( $whichPool == "" ) {

    //if ( $capFileInd == "true" ) {

      foreach ($poolArray as $theKey => $bladeArray ) 
      {

        echo $theKey . $poolDelimiter;

        $bladeCount = 0;
        foreach ($bladeArray as $bladeName ) 
        {

          if ( $bladeCount > 0 ) {
            echo $bladeDelimiter;
          }
          echo $bladeName;

          $bladeCount++;
        }
        echo "\n";
      }
    
  } else {
    // The pool was specified, so only give the count for that pool
    echo $poolArray[$whichPool];
  }
*/
}
catch (Exception $e) {
echo "Error!\n";
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

function poolNameHasSuffix($txt,$key)
{
  return $tmp;
}

?> 

