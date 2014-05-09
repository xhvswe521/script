namespace :rollback do
  desc "rollback:package"
  task :package, :on_error => :continue do

	#deploy for each host or roles
	def deploy_rollback(pre_build_label)
	

	if	ENV['HOSTS']
    	servers = find_servers_for_task(current_task)
    	targets = Commons.targets_by_roles(servers)
	 
		command = "/nas/reg/bin/naslink -b #{pre_build_label};"
    	run("
        if [ -f /var/www/maintenance/in-pool.html ]; then
          if [ `cat /var/www/maintenance/in-pool.html` == 'true' ]; then
            echo 'machine in service, can not do anything';
            exit 1; 
          fi;
        fi;
        #{command}")
	elsif ENV['ROLES']	
    	servers = find_servers_for_task(current_task)
    	targets = Commons.targets_by_roles(servers)
	 
		command = "/nas/reg/bin/naslink -b #{pre_build_label};"
    	run("
        if [ -f /var/www/maintenance/in-pool.html ]; then
          if [ `cat /var/www/maintenance/in-pool.html` == 'true' ]; then
            echo 'machine in service, can not do anything';
            exit 1; 
          fi;
        fi;
        #{command}")
		
	end
begin
    $retry=5
    $num=0
    until Thread.current[:failed_sessions].length<1 do
#        puts "  * \033[1m\033[31mfailed blades:\033[0m#{Thread.current[:failed_sessions].join(",")}"
        ENV['ROLES']=nil
        ENV['HOSTS']=Thread.current[:failed_sessions].join(",")
        Thread.current[:failed_sessions].clear
        run("#{command}")
        $num=$num+1
        if $num >= $retry
        puts "  * \033[1m\033[31mfailed blades:\033[0m#{Thread.current[:failed_sessions].join(",")}"
		break
		end
	end
end  

    # check after deployment 
    command = "readlink -f /nas/deployed"
    used_build = capture("#{command}")
    used_build.chomp!()
    puts("  * use build: #{used_build} after deployment")
    if Thread.current[:failed_sessions].length>=1
      puts "  * \033[1m\033[31mfailed blades:\033[0m#{Thread.current[:failed_sessions].join(",")}"
    end
    # complete
    puts("  * complete deploy:env operation")  
	servers = servers.to_a-Thread.current[:failed_sessions]
    Thread.current[:failed_sessions].clear
	Databse.Deploy_data(servers,"#{pre_build_label}","rollback:package")
	end
	
	#prepare the data from DB
#begin

 #  targets = Commons.targets_by_roles(servers)
	
	label_host = Hash.new
    if ENV['HOSTS']
		hostlist = ENV['HOSTS'].split(",")
		#make the same hostname into group by label
		hostlist.each{|v|
			host = v
			pre_build_label = Databse.Deploy_Rollback_H(host)
			if pre_build_label.to_s == ""
					puts "Don't  have pre_label of #{host}"
			elsif label_host.has_key?("#{pre_build_label}")
					label_host["#{pre_build_label}"].push(host)
			elsif 
					new_label_host = Array.new
					label_host["#{pre_build_label}"] = new_label_host
					label_host["#{pre_build_label}"].push(host)

			end
		}	
		#Loop deploy_rollback by label		
		label_host_array = label_host.to_a
		length = label_host_array.length
		i = 0
		while i<length do
			ENV['HOSTS'] = label_host_array[i][1].join(",")
			pre_build_label = label_host_array[i][0]
    		servers = find_servers_for_task(current_task)
      		Mylogger.info("Affected hosts:#{servers.join(",")}","cap #{current_task.fully_qualified_name} HOSTS=#{ENV['HOSTS']}")
			deploy_rollback("#{pre_build_label}")
			i=i+1
		end
    elsif ENV['ROLES']
		rolelist = ENV['ROLES'].split(",")
		rolelist.each{|v|
				role = v
#				ENV['HOSTS'] = nil
#				ENV['ROLES'] = role
				pre_build_label = Databse.Deploy_Rollback_R(role)	

				if pre_build_label.to_s == ""
						puts "Don't  have pre_label of #{role}"
				elsif label_host.has_key?("#{pre_build_label}")
						label_host["#{pre_build_label}"].push(role)
				elsif 
						new_label_host = Array.new
						label_host["#{pre_build_label}"] = new_label_host
						label_host["#{pre_build_label}"].push(role)
				end

				
		}
		#Loop deploy_rollback by label		
		label_host_array = label_host.to_a
		length = label_host_array.length
		i = 0
		while i<length do
			ENV['ROLES'] = label_host_array[i][1].join(",")
			pre_build_label = label_host_array[i][0]
    		servers = find_servers_for_task(current_task)
      		Mylogger.info("Affected hosts:#{servers.join(",")}","cap #{current_task.fully_qualified_name} ROLES=#{ENV['ROLES']}")
			puts ENV['ROLES'],pre_build_label
			deploy_rollback("#{pre_build_label}")
			i=i+1
		end	
    end

#rescue Exception => e
#		 puts "Exception occured"
#		 puts e
#end


end   
end
