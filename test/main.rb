path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

auth_session = "b2JpOjRFQkVGNTVBOvyrfMupYQCL0CwIC146XoJAO5Jo"


data = {:section => "admins",
             :key => "obi",
                :value => "trusted"}
    #Couchdb.set_config data

#hash = Couchdb.login(username = 'obi',password ='trusted') 
#puts hash.inspect


#hash = Couchdb.add_finder({:database => 'contacts', :key => 'firstname'}, auth_session)

 #puts hash.inspect 
        
 doc = { :database => 'contacts', :design_doc => 'more_views', :json_doc => '/home/obi/bin/leanback/test/my_views.json' }
 #hash = Couchdb.create_design doc, auth_session      
 #puts hash.inspect

view = {:database => 'contacts',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/my_views.json'}
     
 #docs = Couchdb.find_on_fly(view,"",auth_session)
 #puts "docs = " + docs.inspect

#view = { :database => "contacts", :design_doc => 'more_views', :view => 'get_email'}
#Couchdb.find view 

view = { :database => 'contacts', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/view_age.json'}

    age = '36'
   #docs = Couchdb.find_on_fly(view,key = age, auth_session)

  #puts "docs = " + docs.inspect

   doc = {:database => 'contacts', :doc_id => '_design/the_view'}
   #hash = Couchdb.view doc, auth_session
   #puts hash.inspect


 #docs = Couchdb.find_by({:database => 'contacts', :lastname => 'winner'}, auth_session) 
 #puts "docs = " + docs.inspect

 #docs = Couchdb.docs_from 'contacts', auth_session
 #puts "docs = " + docs.inspect
