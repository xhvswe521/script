#!/usr/local/bin/ruby
require 'net/smtp'
require 'pp'


$mail_body =<<END_STR    
<table id="customer-tab" border="1" cellspacing="0px" width="80%" bordercolor="#A7C942" style="border-collapse:collapse" cellpadding="5px">
<tr>
<th><p align=\"center\">ROLES</p></th>
<th><p align=\"center\">LEVEL</p></th>
</tr>
END_STR
@array_result = Array.new
File.open("/nas/home/quwang/script/level_check/var.dat","r+") do |file|
        while $line = file.gets
	puts $line	

def command1(str)
	@command = `ssh srwd83#{str.chomp}001.srwd83.com readlink -f /opt/jboss/server/default/deploy/stubhub/|awk -F'/' '{print $4}'`	
	@array_result.push([str.chomp,@command.chomp])
end

command1("#{$line}")
        end

end
@array_result = @array_result.sort {|x,y| y[1] <=> x[1] }
l = @array_result.length
i =  0
while i < l do
        $mail_body+="<tr>\n"
        $mail_body+="<th><p align=\"center\">#{@array_result[i][0]}</p></th>\n"
        $mail_body+="<th><p align=\"center\">#{@array_result[i][1]}</p></th>\n"
        $mail_body+="</tr>\n"
	i = i+1
end


	$mail_body<< "</tbody>\n"
	$mail_body<< "</table>\n"

puts $mail_body

$message =<<MESSAGE_END
From: Private Person <iceskysl@eoemobile.com>
To: A Test User <quwang@ebay.com>
MIME-Version: 1.0
Content-type: text/html
Subject: SMTP e-mail test
This is an e-mail about the level of the different roles.
<html lang="en-US" xmlns:sh="http://www.stubhub.com/NS/wp" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
      <title>run away server List</title>
        <style>         
        </style>
  </head>
  <body> 
  <p>Hi,all!</p>
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



=begin
$message =<<MESSAGE_END
From: <quwang@ebay.com>
To: <admin@ebay.com>
MIME-Version: 1.0
Content-type: text/html
Subject: Level of Roles
This is an e-mail about the level of the different roles.
<html lang="en-US" xmlns:sh="http://www.stubhub.com/NS/wp" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
      <title>run away server List</title>
        <style>         
        </style>
  </head>
  <body> 
  <p>Hi,all!</p>
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

=end

=begin
begin
        Net::SMTP.start('localhost',25)do |smtp|
        #smtp.sendmail($message,'admin@ebay.com',['quwang@ebay.com','xcai1@ebay.com','ytong@ebay.com','rujli@ebay.com'])
        smtp.sendmail($message,'admin@ebay.com',['quwang@ebay.com','249930776@qq.com'])
        end
rescue Exception => e
        print "Exception occured: " + e
end
=end
