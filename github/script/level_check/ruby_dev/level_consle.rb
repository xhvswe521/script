#!/usr/local/bin/ruby
#
#

`cd /nas/home/quwang/script/task3_ruby/result/;rm mail`

File.open("/nas/home/quwang/tem/var/var.sh","r+") do |file|
	while line = file.gets
#		  puts line
		  $var1 = line[0..4]
	      	  $var2 = line[6..10]
#  		  puts $var1,$var2


def command1(str)
		puts "------------The level information of ROLES #{str} ------------"	
	       	command = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{str} 2>&1 | grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq\\`
		puts command

	        #write the result to file;      
		@FilePath = "/nas/home/quwang/script/task3_ruby/result/level_check_#{str}"
		File.open("#{@FilePath}",'w+') do |file|
		file.puts(command)
		end 
end
		  if $var1=="sws06"
			  puts "------------The level information of ROLES sws ------------"
			  command = `cd /nas/utl/presidio/;cap checkup:package ROLES=sws06  2>&1 | grep "out" | awk '{print $5}'| sort | uniq\\`
			  puts(command)
		  elsif $var1==""||$var2==""
			   command1("#{$var1}")
		  else
		  	  
		  command1("#{$var1}")
		  command1("#{$var2}")
		  puts "------------The DIFFERENCE LEVEL BETWEEN #{$var1} and #{$var2}------------"
		  command = `cd /nas/home/quwang/script/task3_ruby/result;diff --suppress-common-lines -y -W70 level_check_#{$var1} level_check_#{$var2}\\`
		  puts command
		  end
	end
end

