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

 should "create a database if it doesn't already exist, and handle exception if it exists" do
       begin 	
        hash = Couchdb.create 'contacts'
        #puts hash.inspect
       rescue => e
          #puts "Error message: " + e.to_s
          #puts "Error value: " + e.error
       end 
  end

  should "delete a database that doesn't exist and handle the exception" do 
      begin
       hash = Couchdb.delete 'buildings'
       #puts hash.inspect
      rescue CouchdbException => e
       #puts "Error message: " + e.to_s
       #puts "Error value: " + e.error
      end
   end

  should "add a finder method to the database or handle exception if a finder already exists" do
      begin
       hash = Couchdb.add_finder(:database => 'contacts', :key => 'email') 
       #puts hash.inspect
       rescue CouchdbException => e
        #puts e.to_s
        #puts e.error
      end
  end

 should "find items by key" do
     #docs = Couchdb.find_by( :database => 'contacts', :email => 'nancy@mail.com')
     docs = Couchdb.find_by( :database => 'contacts', :lastname => 'smith') 
     #docs = Couchdb.find_by( :database => 'contacts', :country => 'female') 
     #puts docs.inspect
 end

  should "view document doc or handle exception" do
     
        doc = {:database => 'monitors', :doc_id => '3-d71c8ee21d6753896f2d08f57a985e94'}
       begin 
        hash = Couchdb.view doc
        #puts hash.inspect
       rescue CouchdbException => e
        #puts e.inspect
        #puts e.error
       end
  end

  should "Query a permanent view that doesn't exist and handle exception" do
    begin
     #puts 'viewing design doc...'
     view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_user_email'}
     hash = Couchdb.find view 
     #puts hash.inspect
    rescue CouchdbException => e
     # puts "Error message: " + e.to_s
     # puts "Error value: " + e.error
    end  
  end


  should "Query a permanent view" do
    view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
    #puts 'viewing design doc...'
    hash = Couchdb.find view 
    #puts hash.inspect
  end


  should "Query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'contacts',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/my_views.json'}

     hash = Couchdb.find_on_fly(view)
     #puts hash.inspect
  end

  should "Query a permanent view by key and create the view on the fly, if it doesn't already exist" do
    view = { :database => 'contacts', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/view_age.json'}

    age = '36'
    hash = Couchdb.find_on_fly(view,key = age)
    puts hash.inspect  
  end

  should "Create a design doc/permanent view or handle exception" do
    doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
    begin 
     hash = Couchdb.create_design doc
     #puts hash.inspect
     rescue CouchdbException => e
        #puts e.to_s
        #puts e.error
    end  
  end

  should "return a display a list of all databases" do
      databases = Couchdb.all
       databases.each do |db_name| 
          # puts db_name
        end
   end

   should "delete a database" do 
       hash = Couchdb.delete 'staff'
       #puts hash.inspect
   end

  should "create a document and handle exception if one occurs" do 
       begin
        data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
         doc = {:database => 'contacts', :doc_id => 'Nancy', :data => data}
         hash = Document.create doc
         #puts hash.inspect    
       rescue CouchdbException => e
        #puts e.to_s
        #puts e.error
      end  
  end

 should  "update the document" do
   #data = {"age" => "42", "lastname" => "arnold", "phone" => "202-456-1234", "hobbies" => "football,running, video gamess" }
   data = {:age => "41", :lastname => "Stevens" }
   doc = { :database => 'contacts', :doc_id => 'john', :data => data}   
   Document.update doc 
 end

 should "edit a document - handle exceptions" do 
        begin
         data = {:firstname => 'john', :lastname =>'smith', :email => 'john@mail.com',:gender=>'male', :_rev=>'2-e813a0e902e3ac114400ff3959a2adde'}
         doc = {:database => 'contacts', :doc_id => 'john', :data => data}
         hash = Document.edit doc
         #puts hash.inspect 
        rescue CouchdbException => e   
          #puts e.to_s
          #puts e.error
        end
  end

   should "create and delete a document -- any handle exceptions" do
     begin

         data = {:firstname => 'James', 
        	 :lastname =>'Nova', 
       		 :phone => '212-234-1234',
        	 :email =>'james@mail.com'}

         doc = {:database => 'contacts', :doc_id => 'james', :data => data}
         #Document.create doc

         doc = {:database => 'contacts', :doc_id => 'James'}
         hash = Document.delete doc
         #puts hash.inspect
      rescue CouchdbException => e   
         #puts e.to_s
         #puts e.error
      end
   end

   should "delete a document with revision number - any handle exceptions" do 
       begin
         doc = {:database => 'contacts', :doc_id => 'james', :rev => '4-4e70528f7400e2e43d6543aec4d8aa2b'}
         hash = Document.delete_rev doc
         #puts hash.inspect
      rescue CouchdbException => e   
         #puts e.to_s
         #puts e.error
      end
   end

   should "display all documents in the database that doesn't exist and handle exception" do 
    begin
      docs = Couchdb.docs_from 'buildings'
    rescue CouchdbException => e
        #puts e.to_s
        #puts e.error
    end  
   end
  


   should "display all documents in the database" do 
      #docs = Couchdb.docs_from 'monitors'
      #puts 'docs = Couchdb.docs_from monitors'
      #docs.each do |d| 
         # puts "_rev: " + d["_rev"]
          #puts "_id: " + d["_id"]    
          #puts "every: " + d["every"]
          #puts "monitor: " + d["monitor"]
          #puts "url: " + d["url"] 
          #puts "test: " + d["test"]
          #puts "contact: " + d["contact"]
          #puts  "via: " + d["via"]
          #puts "notify_interval: " + d["notify_interval"]
       #end
   end



  should " switch to default bind address" do
     Couchdb.address = nil
     Couchdb.port = nil
     #Couchdb.all
  end
  
end





