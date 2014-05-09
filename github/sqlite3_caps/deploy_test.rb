namespace :deploy_test do
  desc "deploy:package"
  task :package, :on_error => :continue do
    
    # set variables
    unless variables.include?(:build_label)
      set(:build_label) do
        Capistrano::CLI.ui.ask " * please specify the build label to deploy: "
      end 
    end
    servers = find_servers_for_task(current_task)
    targets = Commons.targets_by_roles(servers)


    # whether run in a correct mode
    Commons.whether_nake_running(targets)
    Commons.whether_run_against_whole_pool(targets)
    Commons.confirm_info()

    if ENV['HOSTS']
      Mylogger.info("Affected hosts:#{servers.join(",")}","cap #{current_task.fully_qualified_name} HOSTS=#{ENV['HOSTS']}")
    elsif ENV['ROLES']
      Mylogger.info("Affected hosts:#{servers.join(",")}","cap #{current_task.fully_qualified_name} ROLES=#{ENV['ROLES']}")
    end
    
    # check before deployment
    command = "readlink -f /nas/deployed"
    used_build = capture("#{command}")
    puts("  * use build: #{build_label} before deployment")
    puts("  * use build: #{used_build} before deployment")
    
    # deploy
    command = "/nas/reg/bin/naslink -b #{build_label}; "
    run("
        if [ -f /var/www/maintenance/in-pool.html ]; then
          if [ `cat /var/www/maintenance/in-pool.html` == 'true' ]; then
            echo 'machine in service, can not do anything';
            exit 1; 
          fi;
        fi;
        #{command}")
begin
    $retry=5
    $num=0
    until Thread.current[:failed_sessions].length<1 do
        puts "  * \033[1m\033[31mfailed blades:\033[0m#{Thread.current[:failed_sessions].join(",")}"
        ENV['ROLES']=nil
        ENV['HOSTS']=Thread.current[:failed_sessions].join(",")
        Thread.current[:failed_sessions].clear
        run("#{command}")
        $num=$num+1
        break if $num >= $retry
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

	#deal the data for database
	servers = servers.to_a-Thread.current[:failed_sessions]
	Databse.Deploy_data(servers,"#{build_label}","deploy:package")
  end
end
