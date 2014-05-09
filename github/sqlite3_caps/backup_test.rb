# backup tasks
namespace :backup_test do   
  module Util
    def Util.get_date_label()
      return Time.new().strftime("%Y-%m-%d")
    end
    def Util.get_timestamp()
      return Time.new().to_f().to_s()
    end
  end
  desc "backup code"
  task :code, :on_error => :continue do
    # make it run sequentially
    default_run_options[:max_hosts] = 1
    target_code_link = "/opt/jboss/server/default/deploy/stubhub"
    
    # prepare for backup 
    unless variables.include?(:backup_dir)
      date_label = Util.get_date_label()
      time_stamp = Util.get_timestamp()
      default_backup_dir = "/nas/utl/backup/"
      target_dir = default_backup_dir + date_label + "/" + time_stamp      
      set(:backup_dir, target_dir)     
    end          
    if backup_dir[-1] != "/" then    
      set(:backup_dir, backup_dir + "/")
    end    
    report = backup_dir + "code.report"
             
    # make dir for backup
    owner = ENV["USER"]
    group = "unixsysadmins"
    system("#{sudo} /bin/mkdir -p #{backup_dir}")
    system("#{sudo} /bin/chown #{owner}:#{group} #{backup_dir}")
    system("#{sudo} /bin/touch #{report}")
    system("#{sudo} /bin/chown #{owner}:#{group} #{report}")
    
    # backup
    command = "/bin/hostname >> #{report}; "
    command += "/bin/ls -ltr #{target_code_link} >> #{report}; " 
    command += "/bin/echo >> #{report}"  
    puts("#{command}")
    run("#{command}")  
    #Insert the data into DB
	Databse.Hosts_data(report,'backup:code')		  
    # print report path
    puts("  * backup code link to #{report}")
    puts("  * compelete backup:code operation")
    
    # restore it
  end
  desc "backup package"
  task :package, :on_error => :continue do
    # make it run sequentially
    default_run_options[:max_hosts] = 1
    
    # prepare for backup 
    unless variables.include?(:backup_dir)
      date_label = Util.get_date_label()
      time_stamp = Util.get_timestamp()
      default_backup_dir = "/nas/utl/backup/"
      target_dir = default_backup_dir + date_label + "/" + time_stamp      
      set(:backup_dir, target_dir)     
    end          
    if backup_dir[-1] != "/" then    
      set(:backup_dir, backup_dir + "/")
    end    
    report = backup_dir + "package.report"
             
    # make dir for backup
    owner = ENV["USER"]
    group = "unixsysadmins"
    system("#{sudo} /bin/mkdir -p #{backup_dir}")
    system("#{sudo} /bin/chown #{owner}:#{group} #{backup_dir}")
    system("#{sudo} /bin/touch #{report}")
    system("#{sudo} /bin/chown #{owner}:#{group} #{report}")
    
    # backup
    command = "/bin/hostname >> #{report}; "
    command += "#{sudo} rpm -qa | grep stubhub | awk -F - '{print \"rb\"$(NF-1)\"-\"$NF}'| sort | uniq >> #{report}; " 
    command += "/bin/echo >> #{report}"  
    run("#{command}")  
      
    # print report path
    puts("  * backup package link to #{report}")
    puts("  * compelete backup:package operation")
    
  end
end
