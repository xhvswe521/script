#!/usr/local/bin/ruby
#
#

#`cd /nas/home/quwang/script/task3_ruby/result/;rm mail`

File.open("/nas/home/quwang/tem/var/var.sh","r+") do |file|
	while line = file.gets
		  $var1 = line[0..4]
	      	  $var2 = line[6..10]
		  @role = line[0..2]
		  @mech1= line[3..4] 
		  @mech2= line[9..10]
		 # puts "#{$var1} #{$var2}"
#		@loca  = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var1} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 0-4|uniq`
#		@mech1 = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var1} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 4-6|uniq`
#		@mech2 = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var2} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 4-6|uniq`
#		@role  = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{$var1} 2>&1|grep '\\[out'|awk '{print $4}'|cut -c 7-9|uniq`

def command1(str)
		
	       	command = `cd /nas/utl/presidio/;cap checkup:code ROLES=#{str} 2>&1 | grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq\\`
		if"#{str}"=="#{$var1}"then
			@command1=command
		else
			@command2=command
		end
		
		

end
		  if $var1=="sws06"
			  command = `cd /nas/utl/presidio/;cap checkup:package ROLES=sws06  2>&1 | grep "out" | awk '{print $5}'| sort | uniq\\`
		  printf("\033[4m%80s\033[0m\n","")
	   	  printf("\033[4m%s%10s%13s%15s%10s%12s%15s\033[0m\n","NAME|","","P#{@mech1}","|","","#{@mech2}","|")
		  printf("\033[4m%s%5s%5s%s\033[0m\n","#{@role} |","  #{command.chomp}  ","|","                                        |")
		  elsif $var1==""||$var2==""
			   command1("#{$var1}")
		  printf("\033[4m%80s\033[0m\n","")
	   	  printf("\033[4m%s%10s%13s%15s%10s%12s%15s\033[0m\n","NAME|","","P#{@mech1}","|","","#{@mech2}","|")
		  printf("\033[4m%s%5s%5s%s\033[0m\n","#{@role} |","  #{@command1.chomp}  ","|","                                    |")
		  else
		  command1("#{$var1}")
		  command1("#{$var2}")
		  command = `cd /nas/home/quwang/script/task3_ruby/result;diff --suppress-common-lines -y -W70 level_check_#{$var1} level_check_#{$var2}\\`
		  puts command.length
		  if command.length!=0 
		  printf("\033[4m%80s\033[0m\n","")
	   	  printf("\033[4m%s%10s%13s%15s%10s%12s%15s\033[0m\n","NAME|","","P#{@mech1}","|","","P#{@mech2}","|")
		  printf("\033[4m%s%5s%5s%s\033[0m\n","#{@role} |","  #{@command1.chomp}  ","|","   #{@command2.chomp}    |")
		  end 
		  end
	end
end

