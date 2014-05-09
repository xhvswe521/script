#!/usr/local/bin/ruby
require 'net/smtp'
`cd /nas/home/quwang/script/task3_ruby/result/;rm mail`

$mail_body =<<END_STR 		
<table id="customer-tab" border="1" cellspacing="0px" width="80%" bordercolor="#A7C942" style="border-collapse:collapse" cellpadding="5px">
END_STR

File.open("/nas/home/quwang/tem/var/var.sh","r+") do |file|
	while line = file.gets
	       	$var1 = line[0..4]
	    	$var2 = line[6..10]
		puts $var1,$var2
    		@role = line[0..2]		  
		@loca  = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var1} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 0-4|uniq`
		@mech1 = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var1} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 4-6|uniq`
		@mech2 = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var2} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 4-6|uniq`

def command1(str)
		
	       	command = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{str} 2>&1 | grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq\\`
		if"#{str}"=="#{$var1}"then
			@command1=command
			@command2=nil
		else
			@command2=command
		end
		
		#write the result to file;      
		@FilePath = "/nas/home/quwang/script/task3_ruby/result/level_check_#{str}"
		File.open("#{@FilePath}",'w+') do |file|
		file.puts(command)
		end 
		
end
		  if $var1=="sws06"
			  @command1 = `cd /nas/utl/presidio/;cap checkup:package ROLES=sws06  2>&1 | grep "out" | awk '{print $5}'| sort | uniq\\`
			  @command2=nil
		  elsif $var1==""||$var2==""
			   command1("#{$var1}")
		  else
		  	  
		  command1("#{$var1}")
		  command1("#{$var2}")
		  command = `cd /nas/home/quwang/script/task3_ruby/result;diff --suppress-common-lines -y -W70 level_check_#{$var1} level_check_#{$var2}\\`
		  end


	$mail_body+="<tr>\n"
	$mail_body+="<th><p align=\"center\">NAME</p></th>\n"
	$mail_body+="<th><p align=\"center\">#{@mech1}</p></th>\n"
	$mail_body+="<th><p align=\"center\">#{@mech2}</p></th>\n"
	$mail_body+="<th><p align=\"center\">NOTES</p></th>\n"
	$mail_body+="</tr>\n"

	$mail_body+="<tr>\n"
	$mail_body+="<th><p align=\"center\">#{@role}</p></th>\n"
	$mail_body+="<th><p align=\"center\">#{@command1}</p></th>\n"
	$mail_body+="<th><p align=\"center\">#{@command2}</p></th>\n"
	$mail_body+="<th><p align=\"center\">DIFF</p></th>\n"
	$mail_body+="</tr>\n"
	
	end
end
$mail_body<< "</tbody>\n"
$mail_body<< "</table>\n"

#send_mail parts


$message =<<MESSAGE_END
From: Private Person <iceskysl@eoemobile.com>
To: A Test User <quwang@ebay.com>
MIME-Version: 1.0
Content-type: text/html
Subject: SMTP e-mail test
This is an e-mail message to be sent in HTML format
<html lang="en-US" xmlns:sh="http://www.stubhub.com/NS/wp" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
      <title>run away server List</title>
	<style>         
	</style>
  </head>
  <body> 
  <p>Mail_Title</p>
   #{$mail_body}
   </body>
</html>
MESSAGE_END
begin   
	Net::SMTP.start('localhost',25)do |smtp|
    	smtp.sendmail($message,'admin@ebay.com','quwang@ebay.com') 
	end
rescue Exception => e  
	print "Exception occured: " + e
end

