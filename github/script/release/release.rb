#!/usr/local/bin/ruby
require 'erb'
require 'yaml'
require 'net/smtp'
include Enumerable

puts "First step:"
puts "		Now reading the data from the file of configuration......"
roles00 = IO.read("/nas/utl/presidio/capconfig/roles00.rb")
roles01 = IO.read("/nas/utl/presidio/capconfig/roles01.rb")
roles05 = IO.read("/nas/utl/presidio/capconfig/roles05.rb")
app     = YAML.load(File.open("/nas/home/xcai1/release/app_config.yaml"))
$dc      = "#{app["input"]["dc"]}"
spe_role= "#{app["speacial_role"]["spe_role"]}"
$cf     = "#{app["CF"]["value"]}"
$role   = "#{app["input"]["role"].downcase}"
$level  = "#{app["release_level"]["level"]}"
arry_role_del = $role.split(",")
arry_spe_role = (spe_role.split(",")&$role.split(","))
arry_role_00 = Array.new
arry_role_05 = Array.new
arry_spe_role_01 = Array.new
arry_spe_role_05 = Array.new
arry_role_level_00 = Array.new
arry_role_level_05 = Array.new
role_level_uniq = Array.new
$role_level = Hash.new
$role_level_p05 = Hash.new

def sendemail(user)
        filename = "/nas/home/xcai1/release/#{$level}.out"
        $content = ""
         File.open(filename,"r+") do |file|
                while $line = file.gets
                        $content = "#{$content}#{$line}"
                end 
         end 

        subject = "The script of release about #{$level}"
        sendmessage = "Subject:"+subject+"\n\n"+$content
        Net::SMTP.start('localhost',25) do|smtp|
                smtp.sendmail(sendmessage,'SA@ebay.com',user)
        smtp.finish
        end 
end


def arry_change(array,str = "a")
	length = array.length
	i = 0
	while i< length do
		array[i]="#{array[i]}#{str}"
		i=i+1
	end
end


def get_tem(template='example.tpl') 
return IO.read("/nas/home/xcai1/release/#{template}") 
end

def get_level(cur_role = 'job00a')
	if($flag == 0) then
		cur_level = `cd /nas/utl/presidio ;cap checkup:code ROLES=#{cur_role} 2>&1|grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq`
		if cur_level == ""
		elsif $role_level.has_key?(cur_level)
	        	$role_level["#{cur_level}"].push(cur_role)	
		elsif
			role_list = Array.new
			$role_level["#{cur_level}"] = role_list
                	$role_level["#{cur_level}"].push(cur_role)
		end
	elsif($flag == 5)
		cur_level = `cd /nas/home/xcai1/release ;./get_level_from_p05 \"su - xcai1 -c \\"cd /nas/utl/presidio;cap checkup:code ROLES=#{cur_role}\\"\"  srwp05mgt001 2>&1 |grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq`
	# 	puts cur_level
		if cur_level == ""
		elsif $role_level_p05.has_key?(cur_level)
	        	$role_level_p05["#{cur_level}"].push(cur_role)	
		elsif
			role_list = Array.new
			$role_level_p05["#{cur_level}"] = role_list
                	$role_level_p05["#{cur_level}"].push(cur_role)
		end
	end
end

=begin
class Roles_level
	include Enumerable
	
	def each
		#-----
	end
end

=end


class List
include ERB::Util
	attr_accessor :template

def initialize(template)
	@template = template
end

def render()
        ERB.new(@template).result(binding)
end

def save(file)
        File.open(file,'w+') do |f| 
        f.write(render)
        end 
end
end

def list_save(tem)
	list = List.new(get_tem(tem))
	list.save("#{$level}.out")
end
	
puts "Second step:"
puts "		Now dealing with the logic and generating the script of release!"
if $dc == "production"
	$arry_role = $role.split(",")
	length = $arry_role.length
	i = 0
	while i < length do
	if roles00.include?$arry_role[i]
		arry_role_00.push("#{$arry_role[i]}00")

	elsif roles01.include?$arry_role[i]
		arry_role_00.push("#{$arry_role[i]}01")

	elsif roles05.include?$arry_role[i]
		arry_role_05.push("#{$arry_role[i]}05")

	end
	i = i+1
	end
        
	roles_00 = arry_role_00.join(",")
	roles_05 = arry_role_05.join(",")
	
	#Add a/b  at the end of each role
	arry_change(arry_role_00,'a')
	roles_00_a = arry_role_00.join(",")
	#Add the role of CF to array on pool a
	arry_roles_a_cf = arry_role_00 + ['cfs01a']
	$roles_a_cf = arry_roles_a_cf.join(",")
	#del sws from array on pool a
	arry_role_00 = arry_role_00-['sws01a']
	$roles_a_sws_jboss = arry_role_00.join(",")
	
	arry_role_00 = roles_00.split(",")
	arry_change(arry_role_00,'b')
	roles_00_b = arry_role_00.join(",")
	#Add the role of CF to array on pool b
	arry_roles_b_cf = arry_role_00 + ['cfs01b']
	$roles_b_cf = arry_roles_b_cf.join(",")

	#del sws from array on pool b
	arry_role_00 = arry_role_00-['sws01b']
	$roles_b_sws_jboss = arry_role_00.join(",")


	arry_change(arry_role_05,'a')
	roles_05_a = arry_role_05.join(",")
	arry_role_05 = roles_05.split(",")
	arry_change(arry_role_05,'b')
	roles_05_b = arry_role_05.join(",")
	
end

if $dc == "prodc"
	$arry_role=$role.split(",")
	arry_change($arry_role,'06')
	$roles_prodc =  $arry_role.join(",")
#	puts $roles
	
	arry_change($arry_role,'a')
	$roles_a =  $arry_role.join(",")
#	puts $roles_a
	
	$arry_role = $role.split(",")
	arry_change($arry_role,'06b')
	$roles_b =  $arry_role.join(",")
#	puts $roles_b
end

if $dc ==  "sjrp"
	$arry_role=$role.split(",")

	length = $arry_role.length
	i = 0
	while i < length do
	if roles00.include?$arry_role[i]
		arry_role_00.push("#{$arry_role[i]}")

	elsif roles01.include?$arry_role[i]
		arry_role_00.push("#{$arry_role[i]}")

	elsif roles05.include?$arry_role[i]
		arry_role_05.push("#{$arry_role[i]}")

	end
	i = i+1
	end
	
#	puts arry_role_00
#	puts arry_role_05
	$roles_00 = arry_role_00.join(",")
	$roles_05 = arry_role_05.join(",")
	
	
end

#deal the level to an regular format
arry_level = $level.split(/\.|-/)
if arry_level[2] == "0" 
	$re_level = "#{arry_level[0]}_#{arry_level[1]}"
else
	$re_level = "#{arry_level[0]}_#{arry_level[1]}_#{arry_level[2]}"
end

#generate the specila role
length_spe = arry_spe_role.length
	j  = 0
while j < length_spe do
	if roles00.include?arry_spe_role[j]
		arry_spe_role_01.push("#{arry_spe_role[j]}00")

	elsif roles01.include?arry_spe_role[j]
		arry_spe_role_01.push("#{arry_spe_role[j]}01")

	elsif roles05.include?arry_spe_role[j]
		arry_spe_role_05.push("#{arry_spe_role[j]}05")

	end
	j = j+1
end
arry_change(arry_spe_role_01,'b')
$spe_role_01 = arry_spe_role_01.join(",")

arry_change(arry_spe_role_05,'b')
$spe_role_05 = arry_spe_role_05.join(",")

#Deal with role and level
$arry_role_level = $role.split(",")
length = $arry_role_level.length
k = 0
#puts $arry_role_level
while k < length do
if roles00.include?$arry_role_level[k]
	arry_role_level_00.push("#{$arry_role_level[k]}00a")
	$flag = 0
	get_level(arry_role_level_00.last)

elsif roles01.include?$arry_role_level[k]
	arry_role_level_00.push("#{$arry_role_level[k]}01a")
	$flag = 0
	get_level(arry_role_level_00.last)

elsif roles05.include?$arry_role[k]
#	puts $arry_role[k]
	arry_role_level_05.push("#{$arry_role_level[k]}05a")
	$flag = 5
	get_level(arry_role_level_05.last)
else
	puts "The ROLES:#{$arry_role_level[k]}  didn't find!"

end
	k = k+1
end

$arry_role_list = Array.new
$arry_role_list_p05 = Array.new
$arry_role_list = $role_level.to_a
$arry_role_list_p05 = $role_level_p05.to_a

#puts $arry_role_list[0][0]
#puts $arry_role_list[0][1]

#puts $arry_role_list



	$check_roles_01 = roles_00 
	$check_roles_05 = roles_05
	$roles_a_01     = roles_00_a
	$roles_a_05     = roles_05_a
	$roles_b_01     = roles_00_b
	$roles_b_05     = roles_05_b

	list_save('release.tpl')

	puts "Last step:"
	puts "		Now sending the script to all member of BUS by email!"
	sendemail(['quwang@ebay.com','xcai1@ebay.com','ytong@ebay.com','stmcintyre@ebay.com'])
	#sendemail(['quwang@ebay.com','249930776@qq.com'])


