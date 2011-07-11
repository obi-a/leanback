path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

class TestLeanback < Test::Unit::TestCase
  #should "probably rename this file and start testing for real" do
   # flunk "hey buddy, you should probably rename this file and start testing for real"
  #end


  should "create a database if it doesn't already exist" do
       hash = Couchdb.create 'staff'
	#puts hash.inspect
  end

 should "create a database if it doesn't already exist" do
	hash = Couchdb.create 'contacts'
	#puts hash.inspect
  end

  should "add a finder method to the database" do
       hash = Couchdb.add_finder(:database => 'contacts', :key => 'email') 
       #puts hash.inspect
  end

 should "find items by key" do
     docs = Couchdb.find_by( :database => 'contacts', :email => 'nancy@mail.com')  
     #puts docs.inspect
 end

  should "view document doc" do
        
        doc = {:database => 'monitors', :doc_id => '3-d71c8ee21d6753896f2d08f57a985e94'}
        hash = Couchdb.view doc
        #puts hash.inspect
  end

  should "Query a permanent view" do
    view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
    puts 'viewing design doc...'
    hash = Couchdb.find view 
    puts hash.inspect
  end

  should "Create a design doc/permanent view" do
    doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
     hash = Couchdb.create_design doc
     #puts hash.inspect
  end

  should "return a display a list of all databases" do
      databases = Couchdb.all
       databases.each do |db_name| 
           #puts db_name
        end
   end

   should "delete a database" do 
       hash = Couchdb.delete 'staff'
       #puts hash.inspect
   end

  should "create a document" do 
        data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
         doc = {:database => 'contacts', :doc_id => 'Nancy', :data => data}
         hash = Document.create doc
         #puts hash.inspect    
  end

 should "edit a document" do 
         data = {:firstname => 'john', :lastname =>'smith', :email => 'john@mail.com',:gender=>'male', :_rev=>'2-e813a0e902e3ac114400ff3959a2adde'}
         doc = {:database => 'contacts', :doc_id => 'john', :data => data}
         hash = Document.edit doc
         #puts hash.inspect    
  end

   should "delete a document" do 
         doc = {:database => 'contacts', :doc_id => 'john', :rev => '3-be02e80490f8e9e610d9a9e33d752316'}
         hash = Document.delete doc
         #puts hash.inspect
   end

   should "display all documents in the database" do 
      docs = Couchdb.docs_from 'monitors'
       puts 'docs = Couchdb.docs_from monitors'
      docs.each do |d| 
         # puts "_rev: " + d["_rev"]
          #puts "_id: " + d["_id"]    
          #puts "every: " + d["every"]
          #puts "monitor: " + d["monitor"]
          #puts "url: " + d["url"] 
          #puts "test: " + d["test"]
          #puts "contact: " + d["contact"]
          #puts  "via: " + d["via"]
          #puts "notify_interval: " + d["notify_interval"]
       end
   end

  should " switch to default bind address" do
     Couchdb.address = nil
     Couchdb.port = nil
     Couchdb.all
  end
  
end





