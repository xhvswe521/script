Rb<%= "#{$level.chomp}" %>	
Backup Config and NAS locations (/nas/utl/backup)
<%if $dc == "production"  %>
<% if $check_roles_05 == ""  %>
cap checkup:health  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort

cap checkup:package  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort

cap checkup:code  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort


cap backup:code  ROLES=<%= "#{$check_roles_01.chomp}" %>

Rsync the build
[COMMAND] ./replicator -l <%= "#{$level.chomp}" %>

[COMMAND]
cap inpool_out ROLES=<%= "#{$roles_a_01.chomp}" %>;



STOP HTTPD and JBOSS on pool A
[COMMAND] 
cap stop:httpd  ROLES=<%= "#{$roles_a_01.chomp}" %>;

cap stop:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>;

Deploy package on pool A
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_a_01.chomp}" %>;



[DOING] Start HTTPD and JBOSS on pool A
[COMMAND]
cap start:httpd  ROLES=<%= "#{$roles_a_01.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>

cap inpool_out ROLES=job00b
cap stop:jboss ROLES=job00b
cap inpool_out ROLES=jos05b
cap stop:jboss ROLES=jos05b

<%if $cf == "true"  %>

CF
ssh srwp01mgt002.stubprod.com

Restart CFN on Pool A Blades 
[COMMAND] cap inpool_out ROLES=cfs01a
[COMMAND] /nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_cfm_cf
           cap restart:cf ROLES=cfs01a

SWAP Pool A/B
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_a_cf.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_cf.chomp}" %>;

<%else%>
SWAP Pool A/B
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_01.chomp}" %>;

<%end %>
FLEX
Mgt002
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb_ecomm_13_4_1/2013-03-15/flex-files.20130315.010326+0000.tar

STATIC

/nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_static_cf
<% if $spe_role_01 %>
cap stop:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>

Deploy Pool B

Stop httpd and jboss; Deploy package; Start httpd and jboss
[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_b_01.chomp}" %>;

cap stop:jboss  ROLES=<%= "#{$roles_b_sws_jboss.chomp}" %>;

Deploy package on pool B
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_b_01.chomp}" %>;


cap start:jboss  ROLES=<%= "#{$roles_b_sws_jboss.chomp}" %>

cap start:httpd  ROLES=<%= "#{$roles_b_01.chomp}" %>

<%if $cf == "true"  %>

Restart cf on pool B
[COMMAND]
cap restart:cf ROLES=cfs01b

Put back in pool B
[COMMAND]

cap inpool_in ROLES=<%= "#{$roles_b_cf.chomp}" %>
<% else %>

Put back in pool B
[COMMAND]

cap inpool_in ROLES=<%= "#{$roles_b_01.chomp}" %>
<% end %>

#Rollback Plan
6.2
<% if $spe_role_01 == "" %>
<% else %>
cap start:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>
<% if $cf == "true"  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b_cf.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_cf.chomp}" %>

<% else  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b_01.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_01.chomp}" %>
<% end %>
6.4

ssh srwp01mgt002.stubprod.com
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_cfm_cf -rollback
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_static_cf -rollback
<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a
<% end %>
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb1303/2013-01-29/flex-files.20130129.013415+0000.tar rollback

6.6

[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_a_01.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>

Deploy package on pool A
[COMMAND]
<% role_level_h = $role_level.length %><% m = 0 %><% while m < role_level_h do %>
cap -s build_label=<%= "#{$arry_role_list[m][0].chomp}" %> deploy:package ROLES=<%= "#{$arry_role_list[m][1].join(",")}" %><% m = m+1 %><% end %> 

Start HTTPD and JBOSS on pool A
[COMMAND]
cap start:httpd ROLES=<%= "#{$roles_a_01.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>

<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a

cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>,cfs01a
<% else %>
cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>

<% end %>

<% else %>
cap checkup:health  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort
cap checkup:health  ROLES=<%= "#{$check_roles_05.chomp}" %> 2>&1 | grep out | sort

cap checkup:package  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort
cap checkup:package  ROLES=<%= "#{$check_roles_05.chomp}" %> 2>&1 | grep out | sort

cap checkup:code  ROLES=<%= "#{$check_roles_01.chomp}" %> 2>&1 | grep out | sort
cap checkup:code  ROLES=<%= "#{$check_roles_05.chomp}" %> 2>&1 | grep out | sort


cap backup:code  ROLES=<%= "#{$check_roles_01.chomp}" %> 
cap backup:code  ROLES=<%= "#{$check_roles_05.chomp}" %>

Rsync the build
[COMMAND] ./replicator -l <%= "#{$level.chomp}" %>

[COMMAND]
cap inpool_out ROLES=<%= "#{$roles_a_01.chomp}" %>;
cap inpool_out ROLES=<%= "#{$roles_a_05.chomp}" %>



STOP HTTPD and JBOSS on pool A
[COMMAND] 
cap stop:httpd  ROLES=<%= "#{$roles_a_01.chomp}" %>;
cap stop:httpd  ROLES=<%= "#{$roles_a_05.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>;
cap stop:jboss  ROLES=<%= "#{$roles_a_05.chomp}" %>

Deploy package on pool A
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_a_01.chomp}" %>;
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_a_05.chomp}" %>



[DOING] Start HTTPD and JBOSS on pool A
[COMMAND]
cap start:httpd  ROLES=<%= "#{$roles_a_01.chomp}" %>
cap start:httpd  ROLES=<%= "#{$roles_a_05.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>
cap start:jboss  ROLES=<%= "#{$roles_a_05.chomp}" %>

cap inpool_out ROLES=job00b
cap stop:jboss ROLES=job00b
cap inpool_out ROLES=jos05b
cap stop:jboss ROLES=jos05b

<%if $cf == "true"  %>

CF
ssh srwp01mgt002.stubprod.com

Restart CFN on Pool A Blades 
[COMMAND] cap inpool_out ROLES=cfs01a
[COMMAND] /nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_cfm_cf
           cap restart:cf ROLES=cfs01a

SWAP Pool A/B
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_a_cf.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_cf.chomp}" %>;
cap inpool_in ROLES=<%= "#{$roles_a_05.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_05.chomp}" %>

<%else%>
SWAP Pool A/B
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_01.chomp}" %>;
cap inpool_in ROLES=<%= "#{$roles_a_05.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_b_05.chomp}" %>

<%end %>
FLEX
Mgt002
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb_ecomm_13_4_1/2013-03-15/flex-files.20130315.010326+0000.tar

STATIC

/nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_static_cf
<% if $spe_role_01 != "" && $spe_role_05 != "" %>
cap stop:jboss ROLES=<%= "#{$spe_role_01}"  %>
cap stop:jboss ROLES=<%= "#{$spe_role_05}"  %>
<% elsif $spe_role_01 == "" && $spe_role_05 %>
cap stop:jboss ROLES=<%= "#{$spe_role_05}"  %>
<% elsif $spe_role_05 == "" && $spe_role_01 %>
cap stop:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>



Deploy Pool B

Stop httpd and jboss; Deploy package; Start httpd and jboss
[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_b_01.chomp}" %>;
cap stop:httpd ROLES=<%= "#{$roles_b_05.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_b_sws_jboss.chomp}" %>;
cap stop:jboss  ROLES=<%= "#{$roles_b_05.chomp}" %>

Deploy package on pool B
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_b_01.chomp}" %>;
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_b_05.chomp}" %>


cap start:jboss  ROLES=<%= "#{$roles_b_sws_jboss.chomp}" %>
cap start:jboss  ROLES=<%= "#{$roles_b_05.chomp}" %>

cap start:httpd  ROLES=<%= "#{$roles_b_01.chomp}" %>
cap start:httpd  ROLES=<%= "#{$roles_b_05.chomp}" %>

<%if $cf == "true"  %>

Restart cf on pool B
[COMMAND]
cap restart:cf ROLES=cfs01b

Put back in pool B
[COMMAND]

cap inpool_in ROLES=<%= "#{$roles_b_cf.chomp}" %>
cap inpool_in ROLES=<%= "#{$roles_b_05.chomp}" %>
<% else %>

Put back in pool B
[COMMAND]

cap inpool_in ROLES=<%= "#{$roles_b_01.chomp}" %>
cap inpool_in ROLES=<%= "#{$roles_b_05.chomp}" %>
<% end %>

#Rollback Plan
6.2
cap start:jboss ROLES=<%= "#{$spe_role_01}"  %>
cap start:jboss ROLES=<%= "#{$spe_role_05}"  %>
<% if $cf == "true"  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b_cf.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_cf.chomp}" %>
cap inpool_in ROLES=<%= "#{$roles_b_05.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_05.chomp}" %>

<% else  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b_01.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_01.chomp}" %>
cap inpool_in ROLES=<%= "#{$roles_b_05.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a_05.chomp}" %>
<% end %>
6.4

ssh srwp01mgt002.stubprod.com
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_cfm_cf -rollback
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_static_cf -rollback
<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a
<% end %>
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb1303/2013-01-29/flex-files.20130129.013415+0000.tar rollback

6.6

[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_a_01.chomp}" %>
cap stop:httpd ROLES=<%= "#{$roles_a_05.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>
cap stop:jboss  ROLES=<%= "#{$roles_a_05.chomp}" %>

Deploy package on pool A
[COMMAND]
<% role_level_h = $role_level.length %><% m = 0 %><% while m < role_level_h do %>
cap -s build_label=<%= "#{$arry_role_list[m][0].chomp}" %> deploy:package ROLES=<%= "#{$arry_role_list[m][1].join(",")}" %><% m = m+1 %><% end %> 
<% role_level_h = $role_level_p05.length %><% m = 0 %><% while m < role_level_h do %>
cap -s build_label=<%= "#{$arry_role_list_p05[m][0].chomp}" %> deploy:package ROLES=<%= "#{$arry_role_list_p05[m][1].join(",")}" %><% m = m+1 %><% end %> 

Start HTTPD and JBOSS on pool A
[COMMAND]
cap start:httpd ROLES=<%= "#{$roles_a_01.chomp}" %>
cap start:httpd ROLES=<%= "#{$roles_a_05.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_a_sws_jboss.chomp}" %>
cap start:jboss  ROLES=<%= "#{$roles_a_05.chomp}" %>

<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a

cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>,cfs01a
cap inpool_in ROLES=<%= "#{$roles_a_05.chomp}" %>
<% else %>
cap inpool_in ROLES=<%= "#{$roles_a_01.chomp}" %>
cap inpool_in ROLES=<%= "#{$roles_a_05.chomp}" %>

<% end %>

<% end %>



<% elsif $dc == "prodc" %>
cap checkup:health  ROLES=<%= "#{$roles_prodc.chomp}" %> 2>&1 | grep out | sort

cap checkup:package  ROLES=<%= "#{$roles_prodc.chomp}" %> 2>&1 | grep out | sort

cap checkup:code  ROLES=<%= "#{$roles_prodc.chomp}" %> 2>&1 | grep out | sort

cap backup:code  ROLES=<%= "#{$roles_prodc.chomp}" %> 


Rsync the build
[COMMAND] ./replicator -l <%= "#{$level.chomp}" %>

[COMMAND]
cap inpool_out ROLES=<%= "#{$roles_a.chomp}" %>;



STOP HTTPD and JBOSS on pool 
[COMMAND] 
cap stop:httpd  ROLES=<%= "#{$roles_prodc.chomp}" %>;

cap stop:jboss  ROLES=<%= "#{$roles_prodc.chomp}" %>;

Deploy package on pool 
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_prodc.chomp}" %>;



[DOING] Start HTTPD and JBOSS on pool 
[COMMAND]
cap start:httpd  ROLES=<%= "#{$roles_prodc.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_a.chomp}" %>

cap inpool_out ROLES=job00b
cap stop:jboss ROLES=job00b
cap inpool_out ROLES=jos05b
cap stop:jboss ROLES=jos05b

<%if $cf == "true"  %>

CF
ssh srwp01mgt002.stubprod.com

Restart CFN on Pool A Blades 
[COMMAND] cap inpool_out ROLES=cfs01a
[COMMAND] /nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_cfm_cf
           cap restart:cf ROLES=fs01a


<%end %>
FLEX
Mgt002
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb_ecomm_13_4_1/2013-03-15/flex-files.20130315.010326+0000.tar

STATIC

/nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_static_cf
<% if $spe_role_01 %>
cap stop:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>

Deploy Pool B

Stop httpd and jboss; Deploy package; Start httpd and jboss
[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_b.chomp}" %>;

cap stop:jboss  ROLES=<%= "#{$roles_b.chomp}" %>;

Deploy package on pool B
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_b.chomp}" %>;


cap start:jboss  ROLES=<%= "#{$roles_b.chomp}" %>

cap start:httpd  ROLES=<%= "#{$roles_b.chomp}" %>

<%if $cf == "true"  %>

Restart cf on pool 
[COMMAND]
cap restart:cf ROLES=cfs01b

<% end %>

#Rollback Plan
6.2
<% if $spe_role_01 == "" %>
<% else %>
cap start:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>
<% if $cf == "true"  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a.chomp}" %>

<% else  %>
[COMMAND]
cap inpool_in ROLES=<%= "#{$roles_b.chomp}" %>;cap inpool_out ROLES=<%= "#{$roles_a.chomp}" %>
<% end %>
6.4

ssh srwp01mgt002.stubprod.com
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_cfm_cf -rollback
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_static_cf -rollback
<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a
<% end %>
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb1303/2013-01-29/flex-files.20130129.013415+0000.tar rollback

6.6

[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_prodc.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_a.chomp}" %>

Deploy package on pool 
[COMMAND]
<% role_level_h = $role_level.length %><% m = 0 %><% while m < role_level_h do %>
cap -s build_label=<%= "#{$arry_role_list[m][0].chomp}" %> deploy:package ROLES=<%= "#{$arry_role_list[m][1].join(",")}" %><% m = m+1 %><% end %> 

Start HTTPD and JBOSS on pool 
[COMMAND]
cap start:httpd ROLES=<%= "#{$roles_prodc.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_prodc.chomp}" %>

<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a

<% end %>



<% elsif $dc == "sjrp" %>

cap checkup:health  ROLES=<%= "#{$roles_00.chomp}" %> 2>&1 | grep out | sort
cap checkup:health  ROLES=<%= "#{$roles_05.chomp}" %> 2>&1 | grep out | sort

cap checkup:package  ROLES=<%= "#{$roles_00.chomp}" %> 2>&1 | grep out | sort
cap checkup:package  ROLES=<%= "#{$roles_05.chomp}" %> 2>&1 | grep out | sort

cap checkup:code  ROLES=<%= "#{$roles_00.chomp}" %> 2>&1 | grep out | sort
cap checkup:code  ROLES=<%= "#{$roles_05.chomp}" %> 2>&1 | grep out | sort

cap backup:code  ROLES=<%= "#{$roles_00.chomp}" %> 
cap backup:code  ROLES=<%= "#{$roles_05.chomp}" %> 


Rsync the build
[COMMAND] ./replicator -l <%= "#{$level.chomp}" %>

[COMMAND]
cap inpool_out ROLES=<%= "#{$roles_00.chomp}" %>;
cap inpool_out ROLES=<%= "#{$roles_05.chomp}" %>;



STOP HTTPD and JBOSS on pool 
[COMMAND] 
cap stop:httpd  ROLES=<%= "#{$roles_00.chomp}" %>;
cap stop:httpd  ROLES=<%= "#{$roles_05.chomp}" %>;

cap stop:jboss  ROLES=<%= "#{$roles_00.chomp}" %>;
cap stop:jboss  ROLES=<%= "#{$roles_05.chomp}" %>;

Deploy package on pool 
[COMMAND]
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_00.chomp}" %>;
cap -s build_label=<%= "#{$level.chomp}" %> deploy:package ROLES=<%= "#{$roles_05.chomp}" %>;



[DOING] Start HTTPD and JBOSS on pool 
[COMMAND]
cap start:httpd  ROLES=<%= "#{$roles_00.chomp}" %>
cap start:httpd  ROLES=<%= "#{$roles_05.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_00.chomp}" %>
cap start:jboss  ROLES=<%= "#{$roles_05.chomp}" %>

cap inpool_in ROLES=<%= "#{$roles_00.chomp}" %>;
cap inpool_in ROLES=<%= "#{$roles_05.chomp}" %>;


<%if $cf == "true"  %>

CF
ssh srwp01mgt002.stubprod.com

Restart CFN on Pool A Blades 
[COMMAND] cap inpool_out ROLES=cfs01a
[COMMAND] /nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_cfm_cf
           cap restart:cf ROLES=fs01a
<%end %>
FLEX
Mgt002
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb_ecomm_13_4_1/2013-03-15/flex-files.20130315.010326+0000.tar

STATIC

/nas/reg/bin/sinstall -tag rb_ecomm_<%= "#{$re_level}"  %>_static_cf
<% if $spe_role_01 %>
cap stop:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>


#Rollback Plan
6.2
<% if $spe_role_01 == "" %>
<% else %>
cap start:jboss ROLES=<%= "#{$spe_role_01}"  %>
<% end %>
<% if $cf == "true"  %>
[COMMAND]
cap inpool_out ROLES=<%= "#{$roles_00.chomp}" %>

<% end %>
6.4

ssh srwp01mgt002.stubprod.com
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_cfm_cf -rollback
/usr/local/reg/bin/sinstall -tag rb<%= "#{$re_level}"  %>_static_cf -rollback
<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a
<% end %>
#/nas/reg/deploy/bin/deploy-flex-to-prod /nas/reg/deploy/releases/rb1303/2013-01-29/flex-files.20130129.013415+0000.tar rollback

6.6

cap inpool_out ROLES=<%= "#{$roles_00.chomp}" %>

[COMMAND]
cap stop:httpd ROLES=<%= "#{$roles_00.chomp}" %>

cap stop:jboss  ROLES=<%= "#{$roles_00.chomp}" %>

Deploy package on pool 
[COMMAND]
<% role_level_h = $role_level.length %><% m = 0 %><% while m < role_level_h do %>
cap -s build_label=<%= "#{$arry_role_list[m][0].chomp}" %> deploy:package ROLES=<%= "#{$arry_role_list[m][1].join(",")}" %><% m = m+1 %><% end %> 

Start HTTPD and JBOSS on pool 
[COMMAND]
cap start:httpd ROLES=<%= "#{$roles_00.chomp}" %>

cap start:jboss  ROLES=<%= "#{$roles_00.chomp}" %>

cap inpool_in ROLES=<%= "#{$roles_00.chomp}" %>
<% if $cf == "true"  %>
cap restart:cf ROLES=cfs01a

cap inpool_in ROLES=<%= "#{$roles_00.chomp}" %>,cfs01a
<% else %>
cap inpool_in ROLES=<%= "#{$roles_00.chomp}" %>

<% end %>


<% else %>
There is no dc about this
<% end %>

