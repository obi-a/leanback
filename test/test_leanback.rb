path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

class TestLeanback < Test::Unit::TestCase
  #should "probably rename this file and start testing for real" do
   # flunk "hey buddy, you should probably rename this file and start testing for real"
  #end


  should "create a database if it doesn't already exist" do
	hash = Couchdb.create 'staff'
	puts hash.inspect
  end

 should "create a database if it doesn't already exist" do
	hash = Couchdb.create 'contacts'
	puts hash.inspect
  end

  #should "return error message illegal database name" do
 #	hash = Couchdb.create 'more books'
#	puts hash.inspect
 # end

  should "return a document by ID" do
        
        doc = {:database => 'monitors', :doc_id => 'ee6f4f65-2b5b-4452-a9c4-fd9d860ec17d'}
        hash = Couchdb.find doc
        puts hash.inspect
  end

  should "return a display a list of all databases" do
      databases = Couchdb.all
        databases.each do |db_name| 
           puts db_name
        end
   end

   should "delete a database" do 
       hash = Couchdb.delete 'staff'
       puts hash.inspect
   end

  should "create a document" do 
        data = {:firstname => 'Mary', :lastname =>'smith', :phone => '212-234-1234',:email =>'john@mail.com'}
         doc = {:database => 'contacts', :doc_id => 'Mary', :data => data}
         hash = Document.create doc
         puts hash.inspect    
  end

 should "edit a document" do 
         data = {:firstname => 'john', :lastname =>'smith', :email => 'john@mail.com',:gender=>'male', :_rev=>'2-e813a0e902e3ac114400ff3959a2adde'}
         doc = {:database => 'contacts', :doc_id => 'john', :data => data}
         hash = Document.edit doc
         puts hash.inspect    
  end

   should "delete a document" do 
         doc = {:database => 'contacts', :doc_id => 'john', :rev => '3-be02e80490f8e9e610d9a9e33d752316'}
         hash = Document.delete doc
         puts hash.inspect
   end

   should "display all documents in the database" do 
      docs = Couchdb.docs_from 'monitors'
       
      docs.each do |d| 
          puts d["_rev"]
          puts d["_id"]    
          puts d["every"]
          puts d["monitor"]
          puts d["url"] 
          puts d["test"]
          puts d["contact"]
          puts d["via"]
          puts d["notify_interval"]
       end
   end

  should " switch to default bind address" do
     Couchdb.address = nil
     Couchdb.port = nil
     Couchdb.all
  end
  
end





