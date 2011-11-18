path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

auth_session = "b2JpOjRFQzE5QThGOl1vWmoCx68CKvF2eJKrZnkCFv1c"
 

data = {:section => "admins",
             :key => "obi",
                :value => "trusted"}
    #Couchdb.set_config data

hash = Couchdb.login(username = 'obi',password ='trusted') 
auth_session =  hash["AuthSession"]





data = {:section => "httpd",
              :key => "port",
                :value => "6980" }
#Couchdb.set_config(data,auth_session) 

#Couchdb.port = "6980"
  

#puts auth_session
# Couchdb.create('staff',auth_session)

#hash = Couchdb.add_finder({:database => 'contacts', :key => 'firstname'}, auth_session)

 #puts hash.inspect 

#user = { :username => "Will.i.am", :password => "trusted", :roles => []}
#hash = Couchdb.add_user(user)
#puts hash.inspect

#user = { :username => "kris", :password => "trusted", :roles => ["drunk"]}
#hash = Couchdb.add_user(user,auth_session)
#puts hash.inspect

#hash = Couchdb.login(username = 'kris',password ='trusted') 
#auth_session =  hash["AuthSession"]
#puts "session = " + auth_session

#user = {:username => "jayz", :password => "trusted", :roles => ["student"], :salt => "whatevathesaltis",:email => 'uzi@aol.com'}

#hash = Couchdb.create_user(user)
#admins can add user roles
#hash = Couchdb.create_user(user, auth_session)

#puts hash.inspect
 
#o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
#salt  =  (0..50).map{ o[rand(o.length)]  }.join;       

#puts salt
data = { :admins => {"names" => ["nancy"], "roles" => ["admin"]},
                   :readers => {"names" => ["nancy"],"roles"  => ["admin"]}
                  }
#data = { :admins => {"names" => [], "roles" => []},
#                   :readers => {"names" => [],"roles"  => []}
#                  }

 #hash = Couchdb.set_security("corn",data,auth_session)
 #puts hash.inspect

 #hash = Couchdb.get_security("corn",auth_session)
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


 #docs = Couchdb.find_by({:database => 'contacts', :lastname => 'Hanna'}, auth_session) 
 #puts "docs = " + docs.inspect

 #docs = Couchdb.docs_from 'contacts', auth_session
 #puts "docs = " + docs.inspect
