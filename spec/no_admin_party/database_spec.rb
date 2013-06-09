require 'spec_base.rb'

#a day in the life of a CouchDB admin user
hash = Couchdb.login(username = 'obi',password ='trusted') 
@@auth_session =  hash["AuthSession"]

data = {:section => "httpd",
              :key => "port",
                :value => "6980" }
Couchdb.set_config(data,@@auth_session) 

Couchdb.port = "6980"


describe "CouchDB " do

it "should create and delete a database" do
  hash = Couchdb.create('employees',@@auth_session)
  hash.to_s.should == '{"ok"=>true}'
  hash = Couchdb.all
  hash.include?("employees").should == true
  hash = Couchdb.delete 'employees',@@auth_session 
  hash.include?("employees").should == false
end

it "should create a database add a finder method to it and then delete the database" do
   Couchdb.create('wiseguys',@@auth_session)
   hash = Couchdb.add_finder({:database => 'wiseguys', :key => 'email'},@@auth_session) 
   hash.include?("_design/email_finder").should == true
   hash.include?("true").should == true
   hash.include?("rev").should == true
   
   doc = {:database => 'wiseguys', :doc_id => '_design/email_finder'}
   hash = Couchdb.view doc
   hash["_id"].should == '_design/email_finder'
   Couchdb.delete 'wiseguys',@@auth_session 
 end

it "should create and view document doc" do
  Couchdb.create('contacts',@@auth_session)
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

it "should count the lastnames named smith" do
  count = Couchdb.count({:database => 'contacts', :lastname => 'smith'},@@auth_session)
  count.should == 1
end

it "should count lastnames named brown" do
  count = Couchdb.count({:database => 'contacts', :lastname => 'brown'},@@auth_session)
  count.should == 0 
end


it "find items by key" do
    docs = Couchdb.find_by({:database => 'contacts', :lastname => 'smith'},@@auth_session)
    d = docs[0]
    d["lastname"].should == "smith"
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/lastname_finder'},@@auth_session)
end

it "should find items by multiple keys" do
 keys = {:gender => 'male',:age => '34'}
 docs = Couchdb.find_by_keys({:database => 'contacts', :keys => keys},@@auth_session)
 d = docs[0]
 d["age"].should == "34"
end

it "should find items by multiple keys using a single key" do
 keys = {:lastname => 'smith'}
 docs = Couchdb.find_by_keys({:database => 'contacts', :keys => keys},@@auth_session)
 d = docs[0]
 d["lastname"].should == "smith"
end

it "should find items by multiple keys" do
 keys = {:gender => 'male',:age => '40'}
 docs = Couchdb.find_by_keys({:database => 'contacts', :keys => keys},@@auth_session)
 docs.should == []
end

it "should count items by multiple keys" do
 keys = {:gender => 'male',:age => '34'}
 count = Couchdb.count_by_keys({:database => 'contacts', :keys => keys},@@auth_session)
 count.should == 1
end

it "should count items by multiple keys" do
 keys = {:gender => 'male',:age => '40'}
 count = Couchdb.count_by_keys({:database => 'contacts', :keys => keys},@@auth_session)
 count.should == 0
end



it "should query a permanent view that doesn't exist and handle exception" do
  begin
     view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_user_email'}
     Couchdb.find view,@@auth_session 
    rescue CouchdbException => e
      e.to_s.should == "CouchDB: Error - not_found. Reason - missing"
      e.error.should == "not_found"
    end  
end

it "should query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'contacts',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/leanback/test/my_view.json'}
     
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
             :json_doc => '/home/obi/bin/leanback/test/view_age.json'}

    age = '34'
    docs = Couchdb.find_on_fly(view,@@auth_session,key = age)
    docs[0].include?("age").should == true
    d = docs[0]
    d["age"].should == '34'
    #verify that the view was created
    doc = {:database => 'contacts', :doc_id => '_design/the_view'}
    hash = Couchdb.view doc,@@auth_session
    hash["_id"].should == '_design/the_view'
    Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/the_view'},@@auth_session)
end

it "should create a design doc/permanent view and query it" do
   doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
   hash = Couchdb.create_design doc,@@auth_session
   hash["id"].should == '_design/more_views'
   hash["ok"].should == true

   view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
   hash = Couchdb.find view,@@auth_session 
   hash[0].has_key?("Firstname").should == true
   hash[0].has_key?("Lastname").should == true
   hash[0].has_key?("Email").should == true

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

it "should test finder options" do

  Couchdb.create('fishes',@@auth_session)

  data = {:firstname => 'aaron', :gender =>'male', :age => '28', :salary => '50000'}
  doc = {:database => 'fishes', :doc_id => 'aaron', :data => data}
  Couchdb.create_doc doc,@@auth_session

  data = {:firstname => 'john', :gender =>'male', :age => '28', :salary => '60000'}
  doc = {:database => 'fishes', :doc_id => 'john', :data => data}
  Couchdb.create_doc doc,@@auth_session

  data = {:firstname => 'peter', :gender =>'male', :age => '45', :salary => '78000'}
  doc = {:database => 'fishes', :doc_id => 'peter', :data => data}
  Couchdb.create_doc doc,@@auth_session

  data = {:firstname => 'sam', :gender =>'male', :age => '28', :salary => '97000'}
  doc = {:database => 'fishes', :doc_id => 'sam', :data => data}
  Couchdb.create_doc doc,@@auth_session


 keys = {:age =>'28', :gender => 'male'}
 hash = Couchdb.find_by_keys({:database => 'fishes', :keys => keys},@@auth_session, options = {:limit => 2, :skip => 1})
 h = hash[0]
 h["firstname"].should == "john"
 hash.length.should == 2
  
  #create the design doc to be queryed in the test
  Couchdb.find_by({:database => 'fishes', :gender => 'male'},@@auth_session)


  view = { :database => "fishes", 
          :design_doc => 'gender_finder', 
            :view => 'find_by_gender'}

  hash = Couchdb.find view,@@auth_session,key=nil, options = {:limit => 2, :skip => 1}
  h = hash[0]
  h["firstname"].should == "john"
  hash.length.should == 2

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},@@auth_session,options = {:limit => 2, :skip => 1})
  h = hash[0]
  h["firstname"].should == "john"
  hash.length.should == 2

 

 hash = Couchdb.find view,@@auth_session,key='male', options = {:descending => true}
 h = hash[0]
 h["firstname"].should == "sam"

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},@@auth_session, options = {:descending => true})
 h = hash[0]
 h["firstname"].should == "sam" 



 hash = Couchdb.find view,@@auth_session,key='male', options = {:limit => 3}
 hash.length.should == 3

 hash = Couchdb.find view,@@auth_session,key=nil, options = {:skip => 2}
 h = hash[0]
 h["firstname"].should == "peter"
 hash.length.should == 2

 hash = Couchdb.find view,@@auth_session,key='male', options = {:descending => true,:limit => 1}
 h = hash[0]
 h["firstname"].should == "sam"
 hash.length.should == 1

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},@@auth_session, options = {:descending => true,:limit => 1})
 h = hash[0]
 h["firstname"].should == "sam"
 hash.length.should == 1

 Couchdb.find_by({:database => 'fishes', :salary => '5000'},@@auth_session)


  view = { :database => "fishes", 
          :design_doc => 'salary_finder', 
            :view => 'find_by_salary'}

 hash = Couchdb.find view, @@auth_session,key=nil, options = {:startkey => "3000", :endkey => "65000"}
 h = hash[0]
 h["firstname"].should == "aaron"
 hash.length.should == 2

 hash = Couchdb.find view, @@auth_session,key=nil, options = {:startkey => "53000", :endkey => "99000",:limit => 2}
 h = hash[0]
 h["firstname"].should == "john"
 hash.length.should == 2
 
 Couchdb.find_by({:database => 'fishes', :salary => ''},@@auth_session, options = {:startkey => "53000", :endkey => "99000",:limit => 2})
 h = hash[0]
 h["firstname"].should == "john"
 hash.length.should == 2

    view = {:database => 'fishes',
         :design_doc => 'my_views',
          :view => 'age_gender',
           :json_doc => '/home/obi/bin/leanback/test/start.json'}

 options = {:startkey => ["28","male"], :endkey => ["28","male"], :limit => 2}
     
 hash = Couchdb.find_on_fly(view,@@auth_session,key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "aaron"
   h1["firstname"].should == "john"
   hash.length.should == 2

 options = {:startkey => ["28","male"], :endkey => ["28","male"], :skip => 1}

  hash = Couchdb.find_on_fly(view,@@auth_session,key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "john"
   h1["firstname"].should == "sam"
   hash.length.should == 2


 options = {:startkey => ["28","male"], :endkey => ["28","male"]}

  hash = Couchdb.find_on_fly(view,@@auth_session,key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "aaron"
   h1["firstname"].should == "john"
   hash.length.should == 3

 Couchdb.delete 'fishes',@@auth_session
end

#database: administration tasks

it "should set a config section, retrieve it and delete it" do
     data = {:section => "sample_config_section",
              :key => "sample_key",
                :value => "sample_value"}
    Couchdb.set_config data,@@auth_session

    data = {:section => "sample_config_section",
              :key => "sample_key"}

     Couchdb.get_config(data,@@auth_session).should == "sample_value"

     Couchdb.delete_config(data,@@auth_session).should == "sample_value"

     lambda {Couchdb.get_config(data,@@auth_session)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - unknown_config_value")   
 end

it "should create an admin user and delete the admin user" do
     data = {:section => "admins",
              :key => "sample_admin",
                :value => "trusted"}
    Couchdb.set_config data,@@auth_session

    data = {:section => "admins",
              :key => "sample_admin"}

    Couchdb.delete_config(data,@@auth_session)
    lambda {Couchdb.get_config(data,@@auth_session)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - unknown_config_value") 
end

it "should set security object on a database, retrieve it and reset it back to original" do
    data = { :admins => {"names" => ["obi"], "roles" => ["admin"]},
                   :readers => {"names" => ["obi"],"roles"  => ["admin"]}
                  }

    hash = Couchdb.set_security("contacts",data,@@auth_session)
    hash["ok"].should == true
    
    hash = Couchdb.get_security("contacts",@@auth_session)
    hash["admins"].should == {"names"=>["obi"], "roles"=>["admin"]}
    hash["readers"].should == {"names"=>["obi"], "roles"=>["admin"]}
 
    data = { :admins => {"names" => [], "roles" => []},
                :readers => {"names" => [],"roles"  => []}
                  }

    hash = Couchdb.set_security("contacts",data,@@auth_session)
    hash["ok"].should == true

    hash = Couchdb.get_security("contacts",@@auth_session)
    hash["admins"].should == {"names"=>[], "roles"=>[]}
    hash["readers"].should == {"names"=>[], "roles"=>[]}
end

it "create a new non-admin user, login user, retrieve user and delete the user" do
 user = { :username => "sample_user", :password => "trusted", :roles => []}
 hash = Couchdb.add_user(user)
 hash["ok"].should == true
 hash["id"].should == 'org.couchdb.user:sample_user'
 
 hash = Couchdb.login(username = 'sample_user',password ='trusted') 
 hash.has_key?("AuthSession").should == true

 doc = {:database => '_users', :doc_id => 'org.couchdb.user:sample_user'}
 hash = Couchdb.view doc,@@auth_session
 hash["_id"].should == 'org.couchdb.user:sample_user'  

 hash = Couchdb.delete_doc doc,@@auth_session
 hash["id"].should == 'org.couchdb.user:sample_user'
 hash["ok"].should == true

 lambda {Couchdb.view(doc,@@auth_session)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - deleted")  
end


it "should non-admin user password, verify new password" do
 user = { :username => "another_sample_user", :password => "trusted", :roles => []}
 hash = Couchdb.add_user(user)
 hash["ok"].should == true
 hash["id"].should == 'org.couchdb.user:another_sample_user'

 Couchdb.change_password(username = 'another_sample_user', new_password = "brown", @@auth_session)
 hash = Couchdb.login(username = 'another_sample_user',password ='brown') 
 hash.has_key?("AuthSession").should == true

 lambda {Couchdb.login(username = 'another_sample_user',password ='trusted')}.should raise_error(CouchdbException,"CouchDB: Error - unauthorized. Reason - Name or password is incorrect.")   

 doc = {:database => '_users', :doc_id => 'org.couchdb.user:another_sample_user'}
 hash = Couchdb.delete_doc doc,@@auth_session

end

it "should delete the database" do
  Couchdb.delete 'contacts',@@auth_session
end

it "should switch to default bind address" do
     data = {:section => "httpd",
              :key => "port",
                :value => "5984" }
    Couchdb.set_config(data,@@auth_session)
  
    #Couchdb.address = nil
    #Couchdb.port = nil
    #Couchdb.all @@auth_session
end

end
