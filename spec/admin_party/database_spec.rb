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




it "should create and view document doc" do
  Couchdb.create('friends')

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

it "should count the lastnames named smith" do
  count = Couchdb.count({:database => 'friends', :lastname => 'smith'})
  count.should == 1
end

it "should count lastnames named brown" do
  count = Couchdb.count({:database => 'friends', :lastname => 'brown'})
  count.should == 0 
end

it "find items by key" do
    docs = Couchdb.find_by({:database => 'friends', :lastname => 'smith'})
    d = docs[0]
    d["lastname"].should == "smith"
    Couchdb.delete_doc({:database => 'friends', :doc_id => '_design/lastname_finder'})
end

it "should query a permanent view that doesn't exist and handle exception" do
  begin
     view = { :database => "friends", :design_doc => 'more_views', :view => 'get_user_email'}
     Couchdb.find view 
    rescue CouchdbException => e
      e.to_s.should == "CouchDB: Error - not_found. Reason - missing"
      e.error.should == "not_found"
    end  
end

it "should query a permanent view and create the view on the fly, if it doesn't already exist" do
    view = {:database => 'friends',
         :design_doc => 'my_views',
          :view => 'get_emails',
           :json_doc => '/home/obi/bin/leanback/test/my_view.json'}
     
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
    view = { :database => 'friends', 
           :design_doc => 'the_view', 
            :view => 'age',
             :json_doc => '/home/obi/bin/leanback/test/view_age.json'}

    age = '34'
    docs = Couchdb.find_on_fly(view,"",key = age)
    docs[0].include?("age").should == true
    d = docs[0]
    d["age"].should == '34'
    #verify that the view was created
    doc = {:database => 'friends', :doc_id => '_design/the_view'}
    hash = Couchdb.view doc
    hash["_id"].should == '_design/the_view'
    Couchdb.delete_doc({:database => 'friends', :doc_id => '_design/the_view'})
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


it "should test finder options" do

  Couchdb.create('fishes')

  data = {:firstname => 'aaron', :gender =>'male', :age => '28', :salary => '50000'}
  doc = {:database => 'fishes', :doc_id => 'aaron', :data => data}
  Couchdb.create_doc doc

  data = {:firstname => 'john', :gender =>'male', :age => '28', :salary => '60000'}
  doc = {:database => 'fishes', :doc_id => 'john', :data => data}
  Couchdb.create_doc doc

  data = {:firstname => 'peter', :gender =>'male', :age => '45', :salary => '78000'}
  doc = {:database => 'fishes', :doc_id => 'peter', :data => data}
  Couchdb.create_doc doc

  data = {:firstname => 'sam', :gender =>'male', :age => '28', :salary => '97000'}
  doc = {:database => 'fishes', :doc_id => 'sam', :data => data}
  Couchdb.create_doc doc
  
  #create the design doc to be queryed in the test
  Couchdb.find_by({:database => 'fishes', :gender => 'male'})


  view = { :database => "fishes", 
          :design_doc => 'gender_finder', 
            :view => 'find_by_gender'}

  hash = Couchdb.find view,"",key=nil, options = {:limit => 2, :skip => 1}
  h = hash[0]
  h["firstname"].should == "john"
  hash.length.should == 2

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},"",options = {:limit => 2, :skip => 1})
  h = hash[0]
  h["firstname"].should == "john"
  hash.length.should == 2

 

 hash = Couchdb.find view,"",key='male', options = {:descending => true}
 h = hash[0]
 h["firstname"].should == "sam"

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},"", options = {:descending => true})
 h = hash[0]
 h["firstname"].should == "sam" 



 hash = Couchdb.find view,"",key='male', options = {:limit => 3}
 hash.length.should == 3

 hash = Couchdb.find view,"",key=nil, options = {:skip => 2}
 h = hash[0]
 h["firstname"].should == "peter"
 hash.length.should == 2

 hash = Couchdb.find view,"",key='male', options = {:descending => true,:limit => 1}
 h = hash[0]
 h["firstname"].should == "sam"
 hash.length.should == 1

 Couchdb.find_by({:database => 'fishes', :gender => 'male'},"", options = {:descending => true,:limit => 1})
 h = hash[0]
 h["firstname"].should == "sam"
 hash.length.should == 1

 Couchdb.find_by({:database => 'fishes', :salary => '5000'})


  view = { :database => "fishes", 
          :design_doc => 'salary_finder', 
            :view => 'find_by_salary'}

 hash = Couchdb.find view, "",key=nil, options = {:startkey => "3000", :endkey => "65000"}
 h = hash[0]
 h["firstname"].should == "aaron"
 hash.length.should == 2

 hash = Couchdb.find view, "",key=nil, options = {:startkey => "53000", :endkey => "99000",:limit => 2}
 h = hash[0]
 h["firstname"].should == "john"
 hash.length.should == 2
 
 Couchdb.find_by({:database => 'fishes', :salary => '5000'},"", options = {:startkey => "53000", :endkey => "99000",:limit => 2})
 h = hash[0]
 h["firstname"].should == "john"
 hash.length.should == 2

    view = {:database => 'fishes',
         :design_doc => 'my_views',
          :view => 'age_gender',
           :json_doc => '/home/obi/bin/leanback/test/start.json'}

 options = {:startkey => ["28","male"], :endkey => ["28","male"], :limit => 2}
     
 hash = Couchdb.find_on_fly(view,"",key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "aaron"
   h1["firstname"].should == "john"
   hash.length.should == 2

 options = {:startkey => ["28","male"], :endkey => ["28","male"], :skip => 1}

  hash = Couchdb.find_on_fly(view,"",key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "john"
   h1["firstname"].should == "sam"
   hash.length.should == 2


 options = {:startkey => ["28","male"], :endkey => ["28","male"]}

  hash = Couchdb.find_on_fly(view,"",key=nil, options)
   h0 = hash[0]
   h1 = hash[1]
   h0["firstname"].should == "aaron"
   h1["firstname"].should == "john"
   hash.length.should == 3

 Couchdb.delete 'fishes'
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
     Couchdb.delete 'friends' 

     lambda {Couchdb.get_config(data)}.should raise_error(CouchdbException,"CouchDB: Error - not_found. Reason - unknown_config_value")   
 end

end
