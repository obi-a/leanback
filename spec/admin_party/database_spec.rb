require 'spec_base.rb'
#ain't no party like an admin party


describe "CouchDB admin party " do


it "should create and delete a database" do
 hash = Couchdb.create('staff')
  hash.to_s.should == '{"ok"=>true}'
  hash = Couchdb.all
  hash.include?("staff").should == true
  hash = Couchdb.delete 'staff' 
  hash.include?("staff").should == false
end

it "should create a database add a finder method to it and then delete the database" do
   Couchdb.create('mobsters')
   hash = Couchdb.add_finder({:database => 'mobsters', :key => 'email'}) 
   hash.include?("_design/email_finder").should == true
   hash.include?("true").should == true
   hash.include?("rev").should == true
   
   doc = {:database => 'mobsters', :doc_id => '_design/email_finder'}
   hash = Couchdb.view doc
   hash["_id"].should == '_design/email_finder'
  Couchdb.delete 'mobsters' 
end


it "find items by key" do
    docs = Couchdb.find_by({:database => 'friends', :lastname => 'winner'})
    d = docs[0]
    d["lastname"].should == "winner"
    Couchdb.delete_doc({:database => 'friends', :doc_id => '_design/lastname_finder'})
end

it "should create and view document doc" do
  data = {:firstname => 'John', 
        	 :lastname =>'smith', 
       		 :phone => '202-234-1234',
        	 :email =>'james@mail.com',
                  :age =>'34',
                  :gender =>'male'}
  doc = {:database => 'friends', :doc_id => 'john', :data => data}
  Couchdb.create_doc doc

  doc = {:database => 'friends', :doc_id => 'john'}
  hash = Couchdb.view doc
  hash["_id"].should == 'john'
end

it "should query a permanent view that doesn't exist and handle exception" do
  begin
     view = { :database => "friends", :design_doc => 'more_views', :view => 'get_user_email'}
     Couchdb.find view 
    rescue CouchdbException => e
      e.to_s.should == "CouchDB: Error - not_found. Reason - deleted"
      e.error.should == "not_found"
    end  
end

it "should query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'friends',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/my_views.json'}
     
    docs = Couchdb.find_on_fly(view)
    docs[0].include?("Email").should == true
    docs[0].include?("Name").should == true
    #verify that the view was created
    doc = {:database => 'friends', :doc_id => '_design/my_views'}
    hash = Couchdb.view doc
    hash["_id"].should == '_design/my_views'
    Couchdb.delete_doc({:database => 'friends', :doc_id => '_design/my_views'}) 
end

it "should query a permanent view by key and create the view on the fly, if it doesn't already exist" do
    view = { :database => 'contacts', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/view_age.json'}

    age = '36'
    docs = Couchdb.find_on_fly(view,"",key = age)
    docs[0].include?("age").should == true
    d = docs[0]
    d["age"].should == '36'
    #verify that the view was created
    doc = {:database => 'contacts', :doc_id => '_design/the_view'}
    hash = Couchdb.view doc
    hash["_id"].should == '_design/the_view'
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/the_view'})
end

it "should create a design doc/permanent view and query it" do
   doc = { :database => 'friends', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
   hash = Couchdb.create_design doc
   hash["id"].should == '_design/more_views'
   hash["ok"].should == true

   view = { :database => "friends", :design_doc => 'more_views', :view => 'get_email'}
   hash = Couchdb.find view 
   hash[0].has_key?("Firstname").should == true
   hash[0].has_key?("Lastname").should == true
   hash[0].has_key?("Email").should == true

  doc = {:database => 'friends', :doc_id => '_design/more_views'}
  hash = Couchdb.view doc
  hash["_id"].should == '_design/more_views'
  Couchdb.delete_doc({:database => 'friends', :doc_id => '_design/more_views'})
end

it "should return a list of all databases in the system" do
   databases = Couchdb.all
   databases.include?("friends").should == true 
end

it "should create a document" do
  data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
  doc = {:database => 'friends', :doc_id => 'Nancy', :data => data}
  hash = Couchdb.create_doc doc 
  hash["id"].should == 'Nancy'
  hash["ok"].should == true

  doc = {:database => 'friends', :doc_id => 'Nancy'}
  hash = Couchdb.view doc 
  hash["_id"].should == 'Nancy'
  hash["firstname"].should == 'Nancy'
  hash["lastname"].should == 'Lee'
  hash["phone"].should == '347-808-3734'
  Couchdb.delete_doc({:database => 'friends', :doc_id => 'Nancy'})
end

it "should update the document" do
   data = {:age => "41", :lastname => "Stevens" }
   doc = { :database => 'friends', :doc_id => 'john', :data => data}   
   hash = Couchdb.update_doc doc 
   hash["id"].should == 'john'
   hash["ok"].should == true

  doc = {:database => 'friends', :doc_id => 'john'}
  hash = Couchdb.view doc
  hash["_id"].should == 'john'
  hash["age"].should == '41'
  hash["lastname"].should == 'Stevens'
  Couchdb.delete_doc({:database => 'friends', :doc_id => 'john'})
end


it "should delete a document after creating it" do
   data = {:firstname => 'Sun', 
        	 :lastname =>'Nova', 
       		 :phone => '212-234-1234',
        	 :email =>'james@mail.com'}

    doc = {:database => 'friends', :doc_id => 'Sun', :data => data}
    Couchdb.create_doc doc
    
    doc = {:database => 'friends', :doc_id => 'Sun'}
    hash = Couchdb.delete_doc doc
    hash["id"].should == 'Sun'
    hash["ok"].should == true
    begin
     doc = {:database => 'friends', :doc_id => 'Sun'}
     Couchdb.view doc
    rescue CouchdbException => e
     e.to_s.should == "CouchDB: Error - not_found. Reason - deleted"
     e.error.should ==  "not_found"
    end
end

#database: administration tasks

it "should set a config section, retrieve it and delete it" do
     data = {:section => "sample_config_section",
              :key => "sample_key",
                :value => "sample_value"}
    Couchdb.set_config data

    data = {:section => "sample_config_section",
              :key => "sample_key"}

     Couchdb.get_config(data).should == "sample_value"

     Couchdb.delete_config(data).should == "sample_value"

     lambda {Couchdb.get_config(data)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - unknown_config_value")   
 end

end
