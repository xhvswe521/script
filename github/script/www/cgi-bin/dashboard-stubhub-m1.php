<html>
<head>
<title>NetOps DashBoard</title>
</head>


<?php
$var1 = $_GET["var1"];

if ( $var1 == 'vs' ) {
echo "<frameset rows=64,*,64>";
echo "<frame name=top scrolling=no noresize target=contents src=/dashboard-header.htm>";
echo "<frameset cols=20%,20%,20%>";
echo "<frame  name=contents src=dashboard-stubhub-vs.php?var1=SJVP01>";
echo "<frame  name=contents src=dashboard-stubhub-vs.php?var1=SJVP00>";
echo "<frame  name=contents src=dashboard-stubhub-vs.php?var1=SJVP02>";
echo "</frameset>";
echo "<frame name=bottom scrolling=no noresize target=contents src=/dashboard-footer-m2.htm>";
echo "<noframes>";
echo "/frameset>";
}
elseif ( $var1 == 'pool' ) {
echo "<frameset rows=64,*,64>";
echo "<frame name=top scrolling=no noresize target=contents src=/dashboard-header.htm>";
echo "<frameset cols=20%,20%,20%>";
echo "<frame  name=contents src=dashboard-stubhub-pm.php?var1=SJVP01>";
echo "<frame  name=contents src=dashboard-stubhub-pm.php?var1=SJVP00>";
echo "<frame  name=contents src=dashboard-stubhub-pm.php?var1=SJVP02>";
echo "</frameset>";
echo "<frame name=bottom scrolling=no noresize target=contents src=/dashboard-footer-m2.htm>";
echo "<noframes>";
echo "/frameset>";
}
else {
echo "<frameset rows=64,*,64>";
echo "<frame name=top scrolling=no noresize target=contents src=/dashboard-header.htm>";
echo "<frameset cols=20%,20%,20%>";
echo "<frame  name=contents src=dashboard-stubhub-bkg.pl?var1=SJVP01>";
echo "<frame  name=contents src=dashboard-stubhub-bkg-share.pl?var1=SJVP00>";
echo "<frame  name=contents src=dashboard-stubhub-bkg-prod2.pl?var1=SJVP02>";
echo "</frameset>";
echo "<frame name=bottom scrolling=no noresize target=contents src=/dashboard-footer-m2.htm>";
echo "<noframes>";
echo "/frameset>";
}

?>

<body>
</body>
</html>
