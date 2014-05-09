module Commons 
  # get dc
  def Commons.get_dc()
    return ENV['HOSTNAME'][0,4].downcase
  end
  
  # get short hostname
  def Commons.get_host(host)
    if host.include?('.')
      host = host.split('.')[0]
    end
    host
  end
   
  # get role file directory
  def Commons.get_role_files
    return File.dirname(__FILE__) + "/../roles*"
  end
  
  # get bin folder
  def Commons.get_bin_folder
    return '/nas/utl/presidio/capconfig/bin'
  end
  
  
  # get role-target mappings
  def Commons.targets_by_roles(servers)
    targets = Hash.new()
    roles = Commons.get_role_files()
    servers.each do |server|
      if server.host == 'rookie' then
        targets['rookie'] = 1
      else 
        machine = server.host.split(".")[0]  
        dc = machine[0..3]   
        role = machine[3..8]
        unless targets.key?(role) then
          if dc =~ /srw/i || dc =~ /sjr/ then
            total = `egrep -e "^server.*#{role}.*," #{roles} | wc -l`
          else
            puts ('  * please specify SRWP or SJRP servers when execute a task')   
            exit
          end 
          cibles = Array.new()
          machines = Array.new()
          targets[role] = Hash.new()
          targets[role]['dc'] = dc
          targets[role]['total'] = total
          targets[role]['cible'] = 0  
          targets[role]['cibles'] = cibles  
          targets[role]['machines'] = machines                              
        end
        targets[role]['cible'] += 1
        targets[role]['cibles'].push(server)
        targets[role]['machines'].push(machine)        
      end      
    end
    return targets
  end
  
  # check whether we are running nakedly
  def Commons.whether_nake_running(targets)
    if targets['rookie'] == 1 then
      puts ('  * please specify ROLES= or HOSTS= when execute a task')
      puts ('  * otherwise, this task will run against all blades')
      exit
    end    
  end 
  
  # whether run against whole pool
  def Commons.whether_run_against_whole_pool(targets)
    targets.keys().sort().each do |role|
      
      # bypass run against whole pool check for sjrp or srwd
      if targets[role]['dc'] =~ /sjrp/i || targets[role]['dc'] =~ /srwd/i || role =~ /p06/i then
        # print warning message
        puts ("  * #{role} has \033[1m\033[31m#{targets[role]['total'].to_i()}\033[0m blades totally," + 
              " and we are going to impact \033[1m\033[31m#{targets[role]['cible'].to_i()}\033[0m blades" +
              " [BYPASSED CHECK]")
      else
        # print warning message
        puts ("  * #{role} has \033[1m\033[31m#{targets[role]['total'].to_i()}\033[0m blades totally," + 
              " and we are going to impact \033[1m\033[31m#{targets[role]['cible'].to_i()}\033[0m blades")
        if targets[role]['total'].to_i() <= targets[role]['cible'].to_i() then
          puts ('  * please check ROLES= or HOSTS= again when execute a task')
          puts ("  * this action will run against whole #{role} pool")
          exit
        end
      end
    end
  end
  
 


 # check whether we are running on a specific role
  def Commons.whether_run_against_wrong_pool(targets, roles)
    goto_stop = false
    targets.keys().sort().each do |role|
      roles.each do |myrole|
        if /#{myrole}/ =~ role && targets[role]['cible'].to_i() > 0 then
          goto_stop = true
          break
        end
      end
      if goto_stop then
        puts ("  * \033[1m\033[31m#{role}\033[0m is invalid . please do not run this task on #{roles.join(', ').upcase()} blades")
        exit
      end
    end
  end

 # check whether we are running against a specific role
  def Commons.whether_run_against_right_pool(targets, roles)
    goto_stop = true
    targets.keys().sort().each do |role|
      roles.each do |myrole|
        if /#{myrole}/ =~ role && targets[role]['cible'].to_i() > 0 then
          goto_stop = false
          break
        end
      end
      if goto_stop then
        puts ("  * \033[1m\033[31m#{role}\033[0m is invalid . please run this task against #{roles.join(', ').upcase()} blades only")
        exit
      end
    end
  end
  
  # confirm what you will do
  def Commons.confirm_info()
    pattern = /^yes$/i
    print("  * are you sure to execute? (yes/no) ")
    flag=STDIN.gets.chomp
    unless pattern.match(flag) then
      puts("  * quit!")
      exit
    end
  end

  # wait jboss_process_stop with timeout 
  def Commons.wait_jboss_stop()	
  bin_folder = Commons.get_bin_folder()
    puts ('  * wait for jboss stop')
    run ("#{bin_folder}" + "/wait_jboss_stop 1")
  end

  # wait jboss_process_stop with timeout
  def Commons.wait_jboss_start()	
    puts ('  * wait for jboss start')
    run ("while [ true ]; do wget -q -O - http://localhost/jmx-console 2>&1 >/dev/null; if [ $? -eq 0 ]; then break; else sleep 10; fi; done;echo 'complete health check, and put it in pool';")
  end
end
