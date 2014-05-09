#!/usr/local/bin/ruby

require 'sqlite3'

begin
    
    db = SQLite3::Database.open "presidio.db"
#    db = SQLite3::Database.open "/nas/utl/presidio/presidio.db"
    
#    db.execute "UPDATE Hosts set Label='test111' where Host='srwp01tst001'"
    db.execute "UPDATE Hosts set Label='test131' where Host='srwp01tst001'"

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
