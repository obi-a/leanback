require 'spec_base.rb'

hash = Couchdb.login(username = 'obi',password ='trusted') 
@@auth_session =  hash["AuthSession"]


describe "CouchDB " do


  
it "should create and delete a database" do
  hash = Couchdb.create('staff',@@auth_session)
  hash.to_s.should == '{"ok"=>true}'
  hash = Couchdb.all
  hash.include?("staff").should == true
  hash = Couchdb.delete 'staff',@@auth_session 
  hash.include?("staff").should == false
end

it "should create a database add a finder method to it and then delete the database" do
   Couchdb.create('mobsters',@@auth_session)
   hash = Couchdb.add_finder({:database => 'mobsters', :key => 'email'},@@auth_session) 
   hash.include?("_design/email_finder").should == true
   hash.include?("true").should == true
   hash.include?("rev").should == true
   
   doc = {:database => 'mobsters', :doc_id => '_design/email_finder'}
   hash = Couchdb.view doc
   hash["_id"].should == '_design/email_finder'
   Couchdb.delete 'mobsters',@@auth_session 
 end

it "find items by key" do
    docs = Couchdb.find_by({:database => 'contacts', :lastname => 'winner'},@@auth_session)
    d = docs[0]
    d["lastname"].should == "winner"
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/lastname_finder'},@@auth_session)
end

it "should create and view document doc" do
  data = {:firstname => 'John', 
        	 :lastname =>'smith', 
       		 :phone => '202-234-1234',
        	 :email =>'james@mail.com',
                  :age =>'34',
                  :gender =>'male'}
  doc = {:database => 'contacts', :doc_id => 'john', :data => data}
  Couchdb.create_doc doc,@@auth_session

  doc = {:database => 'contacts', :doc_id => 'john'}
  hash = Couchdb.view doc,@@auth_session
  hash["_id"].should == 'john'
end

it "should query a permanent view that doesn't exist and handle exception" do
  begin
     view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_user_email'}
     Couchdb.find view,@@auth_session 
    rescue CouchdbException => e
      e.to_s.should == "CouchDB: Error - not_found. Reason - deleted"
      e.error.should == "not_found"
    end  
end

it "should query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'contacts',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/my_views.json'}
     
    docs = Couchdb.find_on_fly(view,@@auth_session)
    docs[0].include?("Email").should == true
    docs[0].include?("Name").should == true
    #verify that the view was created
    doc = {:database => 'contacts', :doc_id => '_design/my_views'}
    hash = Couchdb.view doc,@@auth_session
    hash["_id"].should == '_design/my_views'
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/my_views'},@@auth_session) 
end

it "should query a permanent view by key and create the view on the fly, if it doesn't already exist" do
    view = { :database => 'contacts', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/view_age.json'}

    age = '36'
    docs = Couchdb.find_on_fly(view,@@auth_session,key = age)
    docs[0].include?("age").should == true
    d = docs[0]
    d["age"].should == '36'
    #verify that the view was created
    doc = {:database => 'contacts', :doc_id => '_design/the_view'}
    hash = Couchdb.view doc,@@auth_session
    hash["_id"].should == '_design/the_view'
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/the_view'},@@auth_session)
end

it "should create a design doc/permanent view" do
   doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
   hash = Couchdb.create_design doc,@@auth_session
   hash["id"].should == '_design/more_views'
   hash["ok"].should == true

  doc = {:database => 'contacts', :doc_id => '_design/more_views'}
  hash = Couchdb.view doc,@@auth_session
  hash["_id"].should == '_design/more_views'
  Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/more_views'},@@auth_session)
end

it "should return a list of all databases in the system" do
   databases = Couchdb.all
   databases.include?("contacts").should == true 
end

it "should create a document" do
  data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
  doc = {:database => 'contacts', :doc_id => 'Nancy', :data => data}
  hash = Couchdb.create_doc doc,@@auth_session 
  hash["id"].should == 'Nancy'
  hash["ok"].should == true

  doc = {:database => 'contacts', :doc_id => 'Nancy'}
  hash = Couchdb.view doc,@@auth_session 
  hash["_id"].should == 'Nancy'
  hash["firstname"].should == 'Nancy'
  hash["lastname"].should == 'Lee'
  hash["phone"].should == '347-808-3734'
  Couchdb.delete_doc({:database => 'contacts', :doc_id => 'Nancy'},@@auth_session)
end

it "should update the document" do
   data = {:age => "41", :lastname => "Stevens" }
   doc = { :database => 'contacts', :doc_id => 'john', :data => data}   
   hash = Couchdb.update_doc doc,@@auth_session 
   hash["id"].should == 'john'
   hash["ok"].should == true

  doc = {:database => 'contacts', :doc_id => 'john'}
  hash = Couchdb.view doc,@@auth_session
  hash["_id"].should == 'john'
  hash["age"].should == '41'
  hash["lastname"].should == 'Stevens'
  Couchdb.delete_doc({:database => 'contacts', :doc_id => 'john'},@@auth_session)
end


it "should delete a document after creating it" do
   data = {:firstname => 'Sun', 
        	 :lastname =>'Nova', 
       		 :phone => '212-234-1234',
        	 :email =>'james@mail.com'}

    doc = {:database => 'contacts', :doc_id => 'Sun', :data => data}
    Couchdb.create_doc doc,@@auth_session
    
    doc = {:database => 'contacts', :doc_id => 'Sun'}
    hash = Couchdb.delete_doc doc,@@auth_session
    hash["id"].should == 'Sun'
    hash["ok"].should == true
    begin
     doc = {:database => 'contacts', :doc_id => 'Sun'}
     Couchdb.view doc,@@auth_session
    rescue CouchdbException => e
     e.to_s.should == "CouchDB: Error - not_found. Reason - deleted"
     e.error.should ==  "not_found"
    end
end

#TODO: add better tests with validations for couchDB configuration methods later

it "should change the timeout key to 78787 " do
     data = {:section => "couch_httpd_auth",
              :key => "timeout",
                :value => "78787"}
    Couchdb.set_config data,@@auth_session
 end
 
it "should return the configuration values" do
  data = {:section => "httpd",
              :key => "port"}
  puts "port = " + Couchdb.get_config(data,@@auth_session)

  data = {:section => "couch_httpd_auth",
              :key => "timeout"}
  puts "timeout = " + Couchdb.get_config(data,@@auth_session)
 end

it "should set sample key values to couchDB configuration" do
     data = {:section => "sample_config_section",
              :key => "sample_key",
                :value => "sample_value"}
     Couchdb.set_config data,@@auth_session
 end

it "should delete couchDB sample configuration" do
     data = {:section => "sample_config_section",
              :key => "sample_key"}
     hash = Couchdb.delete_config data,@@auth_session
     puts hash.inspect
 end

it "should add an admin user" do
    # data = {:section => "admins",
    #          :key => "obi",
    #            :value => "trusted"}
    #Couchdb.set_config data
end

it "should login a user" do
   #hash = Couchdb.login(username = 'obi',password ='trusted') 
   #puts hash.inspect
   #sleep
end

it "should switch to default bind address" do
     #Couchdb.address = nil
     #Couchdb.port = nil
     #Couchdb.all
  end



end
