#!/usr/local/bin/ruby
require 'net/smtp'

def sendemail(content)
	subject = 'the script of release'
	sendmessage = "Subject:"+subject+"\n\n"+content
	Net::SMTP.start('localhost',25) do|smtp|
	smtp.sendmail(sendmessage,'SA@ebay.com','quwang@ebay.com')
	smtp.finish
	end	
end

def sendemail_file()
	filename = "/nas/home/quwang/test"
	$content = ""  
	File.open(filename,"r+") do |file|   
		while 
			$line = file.gets
			$content = "#{$content}#{$line}"

	end  
	end
	sendemail("#{$content}")   
end  
sendemail_file()
