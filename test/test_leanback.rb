path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

class TestLeanback < Test::Unit::TestCase
  #should "probably rename this file and start testing for real" do
   # flunk "hey buddy, you should probably rename this file and start testing for real"
  #end


  should "create a database if it doesn't already exist" do
      hash = Couchdb.create 'staff'
      assert_equal '{"ok"=>true}', hash.to_s
      response = RestClient.get 'http://127.0.0.1:5984/_all_dbs', {:content_type => :json}
      assert_equal true,response.include?("staff")
  end

 should "create a database if it doesn't already exist, and handle exception if it exists" do
       begin 	
        hash = Couchdb.create 'contacts'
        assert_equal '{"ok"=>true}', hash.to_s
       rescue => e
          assert_equal "CouchDB: Error - file_exists. Reason - The database could not be created, the file already exists.", e.to_s
          assert_equal "file_exists", e.error
       end 
  end

  should "try to delete a database that doesn't exist and handle the exception" do 
      begin
       hash = Couchdb.delete 'buildings'
       #puts hash.inspect
      rescue CouchdbException => e
       assert_equal "CouchDB: Error - not_found. Reason - missing", e.to_s
       assert_equal "not_found", e.error
      end
   end

  should "add a finder method to the database or handle exception if a finder already exists" do
       hash = Couchdb.add_finder(:database => 'contacts', :key => 'email') 
        assert_equal true,hash.include?("_design/email_finder")
        assert_equal true,hash.include?("true")
        assert_equal true,hash.include?("rev")
        
        doc = {:database => 'contacts', :doc_id => '_design/email_finder'}
        hash = Couchdb.view doc
        assert_equal '_design/email_finder', hash["_id"] 
  end

 should "find items by key" do
     #docs = Couchdb.find_by( :database => 'contacts', :email => 'nancy@mail.com')
     docs = Couchdb.find_by( :database => 'contacts', :lastname => 'smith') 
     #docs = Couchdb.find_by( :database => 'contacts', :country => 'female') 
     
     d = docs[0]
     assert_equal "smith", d["lastname"] 
 end

  should "create and view document doc" do

        data = {:firstname => 'John', 
        	 :lastname =>'smith', 
       		 :phone => '202-234-1234',
        	 :email =>'james@mail.com',
                  :age =>'34',
                  :gender =>'male'}

         doc = {:database => 'contacts', :doc_id => 'john', :data => data}
         Couchdb.create_doc doc
     
        doc = {:database => 'contacts', :doc_id => 'john'}
        hash = Couchdb.view doc
        assert_equal 'john', hash["_id"] 
  end

  should "Query a permanent view that doesn't exist and handle exception" do
    begin
     view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_user_email'}
     Couchdb.find view 
    rescue CouchdbException => e
      assert_equal "CouchDB: Error - not_found. Reason - missing_named_view", e.to_s
      assert_equal "not_found", e.error
    end  
  end


  should "Query a permanent view" do
    view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
    docs = Couchdb.find view 
    assert_equal true,docs[0].include?("Email")
    assert_equal true,docs[0].include?("Lastname")
  end


  should "Query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'contacts',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/my_views.json'}
     
     docs = Couchdb.find_on_fly(view)
     #assert_equal true,docs[0].include?("Email")
     #assert_equal true,docs[0].include?("Name")
     #verify that the view was created
     #doc = {:database => 'contacts', :doc_id => '_design/my_views'}
     #hash = Couchdb.view doc
     #assert_equal '_design/my_views', hash["_id"]
  end

  should "Query a permanent view by key and create the view on the fly, if it doesn't already exist" do
    view = { :database => 'contacts', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/view_age.json'}

    age = '36'
    docs = Couchdb.find_on_fly(view,key = age)
    assert_equal true,docs[0].include?("age")
    d = docs[0]
    assert_equal '36', d["age"]
    verify that the view was created
    doc = {:database => 'contacts', :doc_id => '_design/the_view'}
    hash = Couchdb.view doc
    assert_equal '_design/the_view', hash["_id"]
  end

  should "Create a design doc/permanent view or handle exception" do
    doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
     hash = Couchdb.create_design doc
     assert_equal '_design/more_views', hash["id"] 
     assert_equal true, hash["ok"] 
     
     doc = {:database => 'contacts', :doc_id => '_design/more_views'}
     hash = Couchdb.view doc
     assert_equal '_design/more_views', hash["_id"] 
  end

  should "return a display a list of all databases" do
      databases = Couchdb.all
      assert_equal true,databases.include?("contacts")
   end

   should "delete a database" do 
       hash = Couchdb.delete 'staff'
       assert_equal true, hash["ok"] 
       response = RestClient.get 'http://127.0.0.1:5984/_all_dbs', {:content_type => :json}
       assert_equal false,response.include?("staff")
   end

  should "create a document and handle exception if one occurs" do 
        data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
         doc = {:database => 'contacts', :doc_id => 'Nancy', :data => data}
         hash = Couchdb.create_doc doc 
         assert_equal 'Nancy', hash["id"] 
         assert_equal true, hash["ok"]  

         doc = {:database => 'contacts', :doc_id => 'Nancy'}
         hash = Couchdb.view doc
         assert_equal 'Nancy', hash["_id"]
         assert_equal 'Nancy', hash["firstname"]
         assert_equal 'Lee', hash["lastname"]
         assert_equal '347-808-3734', hash["phone"]
  end

 should  "update the document" do
   #data = {"age" => "42", "lastname" => "arnold", "phone" => "202-456-1234", "hobbies" => "football,running, video gamess" }
   data = {:age => "41", :lastname => "Stevens" }
   doc = { :database => 'contacts', :doc_id => 'john', :data => data}   
   hash = Couchdb.update_doc doc 
   assert_equal 'john', hash["id"] 
   assert_equal true, hash["ok"]  
   
   doc = {:database => 'contacts', :doc_id => 'john'}
   hash = Couchdb.view doc
   assert_equal 'john', hash["_id"]
   assert_equal '41', hash["age"]
   assert_equal 'Stevens', hash["lastname"]
   Couchdb.delete_doc :database => 'contacts', :doc_id => 'john'
 end

 should "delete sample documents - ready for next test run" do
      Couchdb.delete_doc :database => 'contacts', :doc_id => 'Nancy'
      Couchdb.delete_doc :database => 'contacts', :doc_id => '_design/more_views'
      #Couchdb.delete_doc :database => 'contacts', :doc_id => '_design/the_view'
      Couchdb.delete_doc :database => 'contacts', :doc_id => '_design/my_views'
      Couchdb.delete_doc :database => 'contacts', :doc_id => '_design/email_finder'
 end

 should "edit a document - handle exceptions" do 
        begin
         #see delete without _rev above
         data = {:firstname => 'john', :lastname =>'smith', :email => 'john@mail.com',:gender=>'male', :_rev=>'2-e813a0e902e3ac114400ff3959a2adde'}
         doc = {:database => 'contacts', :doc_id => 'john', :data => data}
         hash = Couchdb.edit_doc doc
         #puts hash.inspect 
        rescue CouchdbException => e   
          assert_equal "CouchDB: Error - conflict. Reason - Document update conflict.", e.to_s
          assert_equal "conflict", e.error
        end
  end

   should "create and delete a document" do
         data = {:firstname => 'Sun', 
        	 :lastname =>'Nova', 
       		 :phone => '212-234-1234',
        	 :email =>'james@mail.com'}

         doc = {:database => 'contacts', :doc_id => 'Sun', :data => data}
         Couchdb.create_doc doc

         doc = {:database => 'contacts', :doc_id => 'Sun'}
         hash = Couchdb.delete_doc doc

        assert_equal 'Sun', hash["id"] 
        assert_equal true, hash["ok"]  
       begin
        doc = {:database => 'contacts', :doc_id => 'Sun'}
        Couchdb.view doc
       rescue CouchdbException => e
        assert_equal "CouchDB: Error - not_found. Reason - deleted", e.to_s
        assert_equal "not_found", e.error
       end
   end

   should "delete a document with revision number - any handle exceptions" do 
       begin
         doc = {:database => 'contacts', :doc_id => 'james', :rev => '4-4e70528f7400e2e43d6543aec4d8aa2b'}
         hash = Couchdb.delete_rev doc
         #puts hash.inspect
      rescue CouchdbException => e   
        assert_equal "CouchDB: Error - conflict. Reason - Document update conflict.", e.to_s
        assert_equal "conflict", e.error
      end
   end

   should "attempt to display all documents in the database that doesn't exist and handle exception" do 
    begin
      docs = Couchdb.docs_from 'buildings'
    rescue CouchdbException => e
        assert_equal "CouchDB: Error - not_found. Reason - no_db_file", e.to_s
        assert_equal "not_found", e.error
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

#TODO: add better tests with validations for couchDB configuration methods later

  should "change the timeout key to 78787 " do
     data = {:section => "couch_httpd_auth",
              :key => "timeout",
                :value => "78787"}
    Couchdb.set_config data
 end
 
should "return the configuration values" do
  data = {:section => "httpd",
              :key => "port"}
  puts "port = " + Couchdb.get_config(data)

  data = {:section => "couch_httpd_auth",
              :key => "timeout"}
  puts "timeout = " + Couchdb.get_config(data)
 end

should "set sample key values to couchDB configuration" do
     data = {:section => "sample_config_section",
              :key => "sample_key",
                :value => "sample_value"}
     Couchdb.set_config data
 end

should "delete couchDB sample configuration" do
     data = {:section => "sample_config_section",
              :key => "sample_key"}
     hash = Couchdb.delete_config data
     puts hash.inspect
 end

should "add an admin user" do
    # data = {:section => "admins",
    #          :key => "obi",
    #            :value => "trusted"}
    #Couchdb.set_config data
end

should "login a user" do
   #hash = Couchdb.login(username = 'obi',password ='trusted') 
   #puts hash.inspect
   #sleep
end

  should " switch to default bind address" do
     Couchdb.address = nil
     Couchdb.port = nil
     #Couchdb.all
  end
  
end





