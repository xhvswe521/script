#!/usr/local/bin/ruby

require 'sqlite3'

begin
    
    db = SQLite3::Database.new "presidio.db"

    db.execute "CREATE TABLE IF NOT EXISTS Hosts(Id INTEGER PRIMARY KEY,
                                   Host TEXT NOT NULL UNIQUE,
                                   Label TEXT DEFAULT 'Not Deployed', 
                                   Role TEXT NOT NULL, 
                                   SubRole TEXT,
                                   CreatedTime TEXT DEFAULT CURRENT_TIMESTAMP,
                                   Status INTEGER NOT NULL
               )"
   

    db.execute "CREATE TABLE IF NOT EXISTS LabelHistory(Id INTEGER PRIMARY KEY,
                                   Host TEXT NOT NULL,
                                   Role TEXT NOT NULL, 
                                   Label TEXT NOT NULL,
                                   Pre_Label TEXT DEFAULT 'Not Deployed',
                                   CreatedTime TEXT DEFAULT CURRENT_TIMESTAMP,
                                   Source TEXT NOT NULL,
                                   Roll_Back TEXT DEFAULT 'N'
			  )"

#	puts "LabelHistory_update_trigger"
    db.execute "CREATE TRIGGER LabelHistory_update_trigger UPDATE OF Label on Hosts WHEN new.Label!=old.Label
				and new.status!='rollback:package' 
				  BEGIN
                    INSERT INTO LabelHistory(Host,Role,Label,Pre_Label,Source,Roll_Back) VALUES(new.Host,new.Role,new.Label,old.Label,'cap','N');
                  END;"
    db.execute "CREATE TRIGGER LabelHistory_update_rb_trigger UPDATE OF Label on Hosts WHEN new.Label!=old.Label and 				new.status='rollback:package'
                  BEGIN
                    INSERT INTO LabelHistory(Host,Role,Label,Pre_Label,Source,Roll_Back) VALUES(new.Host,new.Role,new.Label,old.Label,'cap','Y');
                  END;"
#	puts "LabelHistory_insert_trigger"
    db.execute "CREATE TRIGGER LabelHistory_insert_trigger AFTER INSERT on Hosts
                  BEGIN
                    INSERT INTO LabelHistory(Host,Role,Label,Source) VALUES(new.Host,new.Role,new.Label,'cron insert');
                  END;"

#    db.execute "INSERT OR REPLACE INTO Hosts(Host,Role,Status) VALUES ('srwp01tst001','tst01',0)"
 #   db.execute "INSERT OR REPLACE INTO Hosts(Host,Role,Status) VALUES ('srwp01tst002','tst01',0)"
  #  db.execute "UPDATE Hosts set Label='test111' where Host='srwp01tst001'"
   # db.execute "INSERT OR REPLACE INTO Hosts(Host,Label,Role,SubRole,Status) VALUES ('srwp01tst001','new label','tst01','tst01a',0)"

#    db.execute "INSERT INTO Friends(Name) VALUES ('Rebecca')"
#    db.execute "INSERT INTO Friends(Name) VALUES ('Jim')"
#    db.execute "INSERT INTO Friends(Name) VALUES ('Robert')"
#    db.execute "INSERT INTO Friends(Name) VALUES ('Julian')"
    
    id = db.last_insert_row_id
    puts "The last id of the inserted row is #{id}"
    
rescue SQLite3::Exception => e 
    
    puts "Exception occured"
    puts e
    
ensure
    db.close if db
end
