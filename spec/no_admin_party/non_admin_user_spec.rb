require 'spec_base.rb'

hash = Couchdb.login(username = 'obi',password ='trusted') 
@@admin_auth_session =  hash["AuthSession"]

user = { :username => "david", :password => "trusted", :roles => []}
Couchdb.add_user(user, @@admin_auth_session)

#a day in the life of the non-admin user
hash = Couchdb.login(username = 'david',password ='trusted') 
@@auth_session =  hash["AuthSession"]

#specs to ensure non-admin users function properly
describe "non admin user" do
 it "should create a document, view, update it" do
  Couchdb.create('contacts',@@admin_auth_session)

  data = {:firstname => 'Nancy', :lastname =>'Lee', :phone => '347-808-3734',:email =>'nancy@mail.com',:gender => 'female'}
  doc = {:database => 'contacts', :doc_id => 'eeek', :data => data}
  hash = Couchdb.create_doc doc,@@auth_session 

  doc = {:database => 'contacts', :doc_id => 'eeek'}
  hash = Couchdb.view doc,@@auth_session
  hash["_id"].should == 'eeek'

  data = {:age => "41", :lastname => "Stevens" }
  doc = { :database => 'contacts', :doc_id => 'eeek', :data => data}   
  hash = Couchdb.update_doc doc,@@auth_session  
  hash["id"].should == 'eeek'
  hash["ok"].should == true    
end

it"should query a view" do
  
 doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
   hash = Couchdb.create_design doc,@@admin_auth_session

   doc = {:database => 'contacts', :doc_id => '_design/more_views'}
   hash = Couchdb.view doc,@@auth_session
   hash["_id"].should == '_design/more_views'
   
   view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
   hash = Couchdb.find view,@@auth_session 
   hash[0].has_key?("Firstname").should == true
   hash[0].has_key?("Lastname").should == true
   hash[0].has_key?("Email").should == true
   Couchdb.delete_doc({:database => 'contacts', :doc_id => '_design/more_views'},@@admin_auth_session) 

    
end


it "should delete document" do
  hash = Couchdb.delete_doc({:database => 'contacts', :doc_id => 'eeek'},@@auth_session)
  hash["id"].should == 'eeek'
  hash["ok"].should == true
  doc = { :database => 'contacts', :doc_id => 'eeek'} 
 lambda {Couchdb.view(doc,@@auth_session)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - deleted")  
end

it "should delete the database and user" do
  doc = {:database => '_users', :doc_id => 'org.couchdb.user:david'}
  Couchdb.delete_doc doc,@@admin_auth_session
  Couchdb.delete 'contacts',@@admin_auth_session
end

end
