#!/usr/local/bin/ruby

require 'sqlite3'

module Databse
	hosts_array=Array.new

	def Databse.get_date_label()
	return Time.new().strftime("%Y-%m-%d %H:%M:%S")
	end 

	#prepare for the data of DB for deploy
	def Databse.Deploy_data(hostname,label,status)
			db = SQLite3::Database.open "/nas/utl/presidio/capconfig/lib/sqlite3/presidio.db"
			creat_time = Databse.get_date_label()
hostname.each{|v|
			machine = v.to_s
			label=label
			status = status
			dc = machine[0..3]
			role_var = machine[6..8] + "a"
			roles    = machine[6..8]
			role = `cat /nas/utl/presidio/capconfig/roles.rb|grep #{machine}`.split("\"")[-1] 


			if(role.include?role_var) then
#				puts "#{roles} is in A pool"
					role = "#{roles}a"
			else
#				puts "#{roles} is in B pool"
					role = "#{roles}b"
			end


			host_var = db.execute "select * from Hosts where Host= '#{machine}'"
			host_var = host_var.to_s
			puts host_var
			if host_var == "" then
#				puts "I"
				db.execute "INSERT INTO Hosts(Host,Label,Role,SubRole,CreatedTime,Status) VALUES ('#{machine}','#{label}','#{roles}','#{role}','#{creat_time}','#{status}')"
			else
#				puts "U"
			 	db.execute  "UPDATE Hosts SET Label='#{label}',Role='#{roles}',SubRole='#{role}',CreatedTime='#{creat_time}',Status='#{status}' where  Host='#{machine}'"
			end

	}
	db.close if db
end
	#prepare the data for deploy:rollback of HOSTS=
	def Databse.Deploy_Rollback_H(host)
		db = SQLite3::Database.open "/nas/utl/presidio/capconfig/lib/sqlite3/presidio.db"
		cur_build_label = db.execute "select DISTINCT Label from Hosts where Host = '#{host}'"
		pre_build_label = db.execute "select Pre_Label from LabelHistory where Host='#{host}' and Label='#{cur_build_label}' and Roll_back='N'"
#		puts cur_build_label,pre_build_label
		return pre_build_label 
 #      deploy_rollback("#{pre_build_label}",host)	
	db.close if db
	end

	#prepare the data for deploy:rollback of ROLES=
	def Databse.Deploy_Rollback_R(role)
		db = SQLite3::Database.open "/nas/utl/presidio/capconfig/lib/sqlite3/presidio.db"
		cur_build_label = db.execute "select DISTINCT Label from Hosts where Role = '#{role}'"
		pre_build_label = db.execute "select DISTINCT Pre_Label from LabelHistory where Role ='#{role}' and Label='#{cur_build_label}' and Roll_back='N'"
		return pre_build_label 
#       deploy_rollback("#{pre_build_label}",role)	
	db.close if db
	end

	#prepare for the data of DB for backup
	def Databse.Hosts_data(backup_dir,status)
	hostname=`cat #{backup_dir} |grep stubprod` 
	creat_time = Databse.get_date_label()
	db = SQLite3::Database.open "/nas/utl/presidio/capconfig/lib/sqlite3/presidio.db"

	hostname.each{|v|
		machine = v.split(".")[0]
			label = `cat #{backup_dir} |grep -A  1 #{machine} |grep release |awk -F/  '{print $11}'`
			label = label.chomp
			if label == ""
				puts "Don't find the Label of #{machine}"
				next
			else					
			dc = machine[0..3]
			role_var = machine[6..8] + "a"
			roles    = machine[6..8]
			role = `cat /nas/utl/presidio/capconfig/roles.rb|grep #{machine}`.split("\"")[-1] 
			if(role.include?role_var) then
#				puts "#{roles} is in A pool"
					role = "#{roles}a"
			else
#				puts "#{roles} is in B pool"
					role = "#{roles}b"
					end


					puts v,machine,role,label
			host_var = db.execute "select * from Hosts where Host= '#{machine}'"
			host_var = host_var.to_s
			puts host_var
			if host_var == "" then
				puts "I"
				db.execute "INSERT INTO Hosts(Host,Label,Role,SubRole,CreatedTime,Status) VALUES ('#{machine}','#{label}','#{roles}','#{role}','#{creat_time}','#{status}')"
			else
				puts "U"
			 	db.execute  "UPDATE Hosts SET Label='#{label}',Role='#{roles}',SubRole='#{role}',Status='#{status}' where  Host='#{machine}'"
			end
			end

	}
	db.close if db
end

#	Databse.Hosts_data

end
