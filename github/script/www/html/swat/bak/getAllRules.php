<?php
header('Content-Type: text/plain');

$Salt = "sa1";
$myFile = "/var/www/cgi-bin/file.php";

$username='dashboard';
$hostname='10.80.132.10';
$location="https://$hostname/iControl/iControlPortal.cgi?";
$rulesWsdl="https://$hostname/iControl/iControlPortal.cgi?WSDL=LocalLB.Rule";

$fp = fopen($myFile, 'r');
$theData = fread($fp, filesize($myFile));
fclose($fp);

$password = decrypt($theData,$Salt);
$regExString = "if {\$uri matches_regex \"^";
$spaces = 26;
$setSubdomain = "set subdomain";
$stubDomain = ".stubhub.com";

try {
  $rulesClient = new SoapClient($rulesWsdl,array('location'=>$location,'login'=>$username,'password'=>$password));
  $ruleList=$rulesClient->query_all_rules();

  // Spit out all rules
  // Loop through the rules
  foreach ($ruleList as $ruleIndex=>$rule)
  {
    // Get the rule name and definition.  The ruleDef contains all the rule text.
    $ruleName = $rule->rule_name;
    $ruleDef = $rule->rule_definition;

    echo "--------------------------------------------------\n";
    echo "Rule Name: " . $ruleName . "\n";
    echo $ruleDef . "\n";
    echo "\n\n";
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


?> 

