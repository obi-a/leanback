path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

#auth_session = "b2JpOjRFQzE5QThGOl1vWmoCx68CKvF2eJKrZnkCFv1c"
 

data = {:section => "admins",
             :key => "obi",
                :value => "trusted"}

 #hash = Couchdb.delete 'staff'

#puts hash.inspect

hash = Couchdb.login(username = 'obi',password ='trusted') 
auth_session =  hash["AuthSession"]


view = { :database => "monitors", 
          :design_doc => 'tag_finder', 
            :view => 'find_by_tag'}
 
#hash = Couchdb.find view,auth_session,key='ralph', options = {:limit => 5, :skip => 1}

#hash = Couchdb.find view,auth_session,key='ralph', options = {:limit => 5}


#Couchdb.find_by({:database => 'zralph1369728249zeb1292e18b998352', :timestamp => 'Smith'},auth_session)

#Couchdb.find_by({:database => 'monitors', :test => 'Smith'},auth_session)

view = { :database => "zralph1369728249zeb1292e18b998352", 
          :design_doc => 'timestamp_finder', 
            :view => 'find_by_timestamp'}

#hash = Couchdb.find view,auth_session,key=nil, options = {:startkey => "100", :endkey => "1369728370"}

#hash = Couchdb.find view,auth_session,key="1369728370"

#start 2013-05-29 20:22:07 -0400 1369873327 
#end 2013-05-29 20:19:07 -0400 1369873147 

view = { :database => "monitors", 
          :design_doc => 'test_finder', 
            :view => 'find_by_test'}
#hash = Couchdb.find view,auth_session,key=nil, options = {:startkey => ["1000","UP"], :endkey => ["6000","UP"]}

#hash = Couchdb.find view,auth_session,key=nil, options = {:startkey => ["3300","UP"],:descending => true}

#hash = Couchdb.find view,auth_session,key=nil, options = {:descending => true}

#hash = Couchdb.find view,auth_session,key= {:keys => ['3300','UP']}

#hash = Couchdb.find view,auth_session,key= '?keys=%5B%228800%22,%22UP%22%5D'

#keys = {:tag =>'ralph', :via => 'ses' }
#hash = Couchdb.find_by_keys({:database => 'monitors', :keys => keys},auth_session)

#keys = {:tag =>'ralph', :via => 'ses' }
#num = Couchdb.count_by_keys({:database => 'monitors', :keys => keys},auth_session)

keys = {:tag =>'ralph', :via => 'ses', :every => '1m'}
hash = Couchdb.find_by_keys({:database => 'monitors', :keys => keys},auth_session, options = {:limit => 1, :skip => 1})

#keys = {:tag =>'ralph', :via => 'ses', :every => '1m'}
#num = Couchdb.count_by_keys({:database => 'monitors', :keys => keys},auth_session)

#keys = {:tag => 'ralph'}
#hash = Couchdb.find_by_keys({:database => 'monitors', :keys => keys},auth_session)

#keys = {:tag => 'ralph'}
#num = Couchdb.count_by_keys({:database => 'monitors', :keys => keys},auth_session)


#Couchdb.add_multiple_finder({:database => "monitors", :keys => ["tag","via"]},auth_session)

#Couchdb.add_multiple_finder({:database => "monitors", :keys => ["tag","via","state"]},auth_session)

#Couchdb.add_multiple_finder({:database => "monitors", :keys => ["tag"]},auth_session)

#puts num.to_s

puts hash.inspect


###END OF KEYS TESTING########

#user = { :username => "david", :password => "trusted", :roles => []}
#Couchdb.add_user(user, auth_session )

#hash = Couchdb.delete 'staff',auth_session

#puts auth_session

#Couchdb.create 'contacts',auth_session

data = {:firstname => 'Linda', 
        :lastname =>'smith', 
        :phone => '212-234-1234',
        :email =>'john@mail.com'}
 
doc = {:database => 'contacts', :doc_id => 'Linda', :data => data}
#Couchdb.create_doc doc,auth_session

data = {:email => "linda@mail.com" }
doc = { :database => 'contacts', :doc_id => 'Linda', :data => data}   
#Couchdb.update_doc doc,auth_session


doc = {:database => 'contacts', :doc_id => 'Linda'}
#x= Couchdb.view doc,auth_session

#puts x.inspect

data = {:firstname => 'Linda', 
        :lastname =>'smith', 
        :email => 'linda@mail.com',
        :gender=>'female',
        :phone =>'718-245-5611',
        :_rev=>'2-d663618eda3268b83f96140b8250bc9e'}
 
doc = {:database => 'contacts', :doc_id => 'Linda', :data => data}
#Couchdb.edit_doc doc,auth_session

doc = {:database => 'contacts', :doc_id => 'Linda'}
#x= Couchdb.view doc,auth_session



#puts x.inspect

#x = Couchdb.find_by({:database => 'contacts', :email => 'linda@mail.com'} , auth_session) 

#puts x.inspect


#Couchdb.delete 'contacts',auth_session

    #Couchdb.set_config data

#hash = Couchdb.login(username = 'obi',password ='trusted') 
#puts hash.inspect

#auth_session =  hash["AuthSession"]


#hash = Couchdb.add_finder({:database => 'mobsters', :key => 'email'}) 

new_password = 'ninja'
#puts new_password
#puts Couchdb.change_password(username = 'kent', new_password, auth_session)

#hash = Couchdb.login(username ,new_password) 
#user_auth_session =  hash["AuthSession"]

#puts user_auth_session

#data = {:section => "httpd",
#              :key => "port"}

data = {:section => "couchdb",
              :key => "database_dir"}

#hash = Couchdb.get_config(data,auth_session)
#puts hash.inspect

data = { :admins => {"names" => ["david"], "roles" => ["admin"]},
                   :readers => {"names" => ["david"],"roles"  => ["admin"]}
                  }

    #hash = Couchdb.set_security("contacts",data,auth_session)
#      hash = Couchdb.get_security("contacts",auth_session)
 #   puts hash.inspect

 data = {:section => "admins",
              :key => "sample_admin",
                :value => "trusted"}
    #Couchdb.set_config data,auth_session

    data = {:section => "admins",
              :key => "sample_admin"}

    #hash = Couchdb.delete_config(data,auth_session)
    #puts "EKE" + hash.inspect

#hash = Couchdb.create 'contactsabc',auth_session
#hash = Couchdb.all,auth_session
#puts hash.inspect

data = {:firstname => 'Linda', 
        :lastname =>'smith', 
        :phone => '212-234-1234',
        :email =>'john@mail.com'}
 
doc = {:database => 'contactsabc', :doc_id => 'Linda', :data => data}
#hash = Couchdb.create_doc doc,auth_session
#puts hash.inspect

#hash = Couchdb.find_by( {:database => 'contactss', :email => 'john@mail.com'},auth_session)  
#puts hash.inspect





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
