#!/usr/local/bin/ruby

$command = `cd /nas/home/quwang/c/proj/ssh/ ;./get_level_from_p05 \"su - xcai1 -c \\"cd /nas/utl/presidio;cap checkup:code ROLES=tkn05a\\"\"  srwp05mgt001 2>&1 |grep '\\[out'|awk '{print $5}'|awk -F\/ '{print $5}'|sort|uniq` 

   	 puts $command
