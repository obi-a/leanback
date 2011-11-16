require 'spec_base.rb'

#a day in the life of the non-admin user
hash = Couchdb.login(username = 'obiora',password ='trusted') 
@@auth_session =  hash["AuthSession"]

hash = Couchdb.login(username = 'obi',password ='trusted') 
@@admin_auth_session =  hash["AuthSession"]

#specs to ensure non-admin users function properly
describe "non admin user" do
 it "should create a document, view, update and delete it" do
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

  Couchdb.delete_doc({:database => 'contacts', :doc_id => 'eeek'},@@auth_session)

  hash["id"].should == 'eeek'
  hash["ok"].should == true
  doc = { :database => 'contacts', :doc_id => 'eeek'} 
 lambda {Couchdb.view(doc,@@auth_session)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - deleted")  
end

it"should create a design doc" do
 doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
   hash = Couchdb.create_design doc,@@admin_auth_session
   
   view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_user_email'}
   Couchdb.find view,@@auth_session 
end

end
