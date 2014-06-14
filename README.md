###Leanback

[![Build Status](https://travis-ci.org/obi-a/leanback.svg?branch=master)](https://travis-ci.org/obi-a/leanback)

Simple Ruby Interface to CouchDB. This current version is a complete re-write with a new API.

### Installation:
```
gem install leanback
```

### Basic Operations:
Initialize leanback

```ruby
my_database = Leanback::Couchdb.new(database: "my_database")
#=> #<Leanback::Couchdb:0x000000034a7b78
# @address="http://127.0.0.1",
# @database="my_database",
# @password=nil,
# @port="5984",
# @username=nil>
```
In the above code, my_database object will be used to perform operations on the couchDB database named "my_database". The above example assumes that the database is in admin party mode, since no username or password was provided.

If there is no admin party then a username and password is required to perform the operations.
A username and password can be included during initialization:
```ruby
my_database = Leanback::Couchdb.new(database: "my_database", username: "obi", password: "abc1234")
#=> #<Leanback::Couchdb:0x000000033fd970
# @address="http://127.0.0.1",
# @database="my_database",
# @password="abc1234",
# @port="5984",
# @username="obi">

```
By default, Leanback uses couchDB's default http address and port (http://127.0.0.1:5984), to use a different address and port, include it in the initialization:
```ruby
my_database = Leanback::Couchdb.new(database: "my_database", address: "https://obi.iriscouch.com", port: "6984")
#=> #<Leanback::Couchdb:0x000000033ab5d0
# @address="https://obi.iriscouch.com",
# @database="my_database",
# @password=nil,
# @port="6984",
# @username=nil>
```

Create database:
```ruby
my_database = Leanback::Couchdb.new(database: "my_database")
my_database.create
#=> {:ok=>true}
```

Delete database
```ruby
my_database.delete
#=> {:ok=>true}
```

Create a document
```ruby
my_database.create_doc("linda", firstname: "linda", lastname: "smith")
#=> {:ok=>true, :id=>"linda", :rev=>"1-ff286690ab5b446a727840ce7420843a"}
```
The created document inside couchDB will be:
```javascript
{
   "_id": "linda",
   "_rev": "1-ff286690ab5b446a727840ce7420843a",
   "firstname": "linda",
   "lastname": "smith"
}
```

Delete the document with it's latest revision
```ruby
my_database.delete_doc("linda", rev = "1-ff286690ab5b446a727840ce7420843a")
#=> {:ok=>true, :id=>"linda", :rev=>"2-d689d9b5b9f2ded6a2157fc9cc84a00f"}
```
Delete the document without providing a revision
```ruby
my_database.delete_doc!("linda")
#=> {:ok=>true, :id=>"linda", :rev=>"4-5d1a6851ec7562378caa4ce4adef9ee4"}
```
delete_doc! with the bang, first fetches the document with the provided id, retrieves it's latest revision and then, deletes the document using the latest revision.

Fetch the document using its id
```ruby
my_database.get_doc('linda')
#=> {:_id=>"linda",
# :_rev=>"5-74894db03ef6d22e6a0e4ef90b5a85fb",
# :firstname=>"linda",
# :lastname=>"smith"}

```

Update the document
```ruby
my_database.update_doc("linda", firstname: "nancy", lastname: "drew", _rev: "5-74894db03ef6d22e6a0e4ef90b5a85fb")
#=> {:ok=>true, :id=>"linda", :rev=>"6-950d16c8c39daa77fad11de85b9467fc"}
```
update_doc replaces the old document with the new data. A revision (_rev) must be provided in the data.  The resulting document after the update will be
```javascript
{
   "_id": "linda",
   "_rev": "6-950d16c8c39daa77fad11de85b9467fc",
   "firstname": "nancy",
   "lastname": "drew"
}

```
Edit parts of a document
```ruby
my_database.edit_doc!("linda", lastname: "brown", phone: "777-777-7777")
#=> {:ok=>true, :id=>"linda", :rev=>"7-e44206dd09d2740171576e5867fff7a1"}
```
The edited version of the document is now:
```javascript
{
   "_id": "linda",
   "_rev": "7-e44206dd09d2740171576e5867fff7a1",
   "firstname": "nancy",
   "lastname": "brown",
   "phone": "777-777-7777"
}

```

###Working with Desgin Documents and views

Create a design document
```ruby
design_doc = {
 language: "javascript",
 views: {
   by_gender: {
     map: "function(doc){ if(doc.gender) emit(doc.gender); }"
   }
 }
}
my_database.create_doc "_design/my_doc", design_doc
#=> {:ok=>true, :id=>"_design/my_doc", :rev=>"1-4939535c4d51fb5bcbc9b32e2f58e755"}
```

Query a permanent view
```ruby
my_database.view("_design/my_doc", "by_gender")
#=> {:total_rows=>7,
# :offset=>0,
# :rows=>
#  [{:id=>"christina", :key=>"female", :value=>nil},
#  {:id=>"lisa", :key=>"female", :value=>nil},
#  {:id=>"nancy", :key=>"female", :value=>nil},
#  {:id=>"susan", :key=>"female", :value=>nil},
#  {:id=>"james", :key=>"male", :value=>nil},
#  {:id=>"kevin", :key=>"male", :value=>nil},
# {:id=>"martin", :key=>"male", :value=>nil}]}
```
The view() method is used to query parmanent views. It takes the design document name and view name as arguments. It can also optionally take the following CouchDB query options in a hash as arguments: key, limit, skip, descending, include_docs, reduce, startkey, starkey_docid, endkey, endkey_docid, inclusive_end, stale, group, group_level.

To query a permanent view by key
```ruby
my_database.view("_design/my_doc", "by_gender", key: '"male"')
#=> {:total_rows=>7,
# :offset=>4,
# :rows=>
#  [{:id=>"james", :key=>"male", :value=>nil},
#   {:id=>"kevin", :key=>"male", :value=>nil},
#   {:id=>"martin", :key=>"male", :value=>nil}]}
```
The above example sends a query to the view using the key "male" and returns all documents with "gender" equal to  "male".

To include actual documents in the query results, we can add include_docs to the query options
```ruby
my_database.view("_design/my_doc", "by_gender", key: '"male"', include_docs: true)
#=> {:total_rows=>7,
# :offset=>4,
# :rows=>
#  [{:id=>"james",
#    :key=>"male",
#    :value=>nil,
#    :doc=>
#     {:_id=>"james",
#      :_rev=>"1-56ff4f73369bdf8350615a58e12e4c3b",
#      :firstname=>"james",
#      :state=>"new york",
#      :gender=>"male",
#      :city=>"manhattan",
#      :age=>23}},
#   {:id=>"kevin",
#    :key=>"male",
#    :value=>nil,
#    :doc=>
#     {:_id=>"kevin",
#      :_rev=>"1-3c6381603d9f15cb966948eb29218cf7",
#      :firstname=>"kevin",
#      :state=>"new york",
#      :gender=>"male",
#      :city=>"bronx",
#      :age=>37}},
#   {:id=>"martin",
#    :key=>"male",
#    :value=>nil,
#    :doc=>
#     {:_id=>"martin",
#      :_rev=>"1-41956cd527d75643171919731abd97c0",
#      :firstname=>"martin",
#      :state=>"new york",
#      :gender=>"male",
#      :city=>"manhattan",
#      :age=>29}}]}
```

To return results in descending order:
```ruby
my_database.view("_design/my_doc", "by_gender", key: '"male"', descending: true)
#=> {:total_rows=>7,
# :offset=>0,
# :rows=>
#  [{:id=>"martin", :key=>"male", :value=>nil},
#   {:id=>"kevin", :key=>"male", :value=>nil},
#   {:id=>"james", :key=>"male", :value=>nil}]}
```

To limit the number of documents returned from the query
```ruby
my_database.view("_design/my_doc", "by_gender", limit: 4)
#=> {:total_rows=>7,
# :offset=>0,
# :rows=>
#  [{:id=>"christina", :key=>"female", :value=>nil},
#   {:id=>"lisa", :key=>"female", :value=>nil},
#   {:id=>"nancy", :key=>"female", :value=>nil},
#   {:id=>"susan", :key=>"female", :value=>nil}]}
```

Skip some documents in the query
```ruby
my_database.view("_design/my_doc", "by_gender", skip: 2)
#=> {:total_rows=>7,
# :offset=>2,
# :rows=>
#  [{:id=>"nancy", :key=>"female", :value=>nil},
#   {:id=>"susan", :key=>"female", :value=>nil},
#   {:id=>"james", :key=>"male", :value=>nil},
#   {:id=>"kevin", :key=>"male", :value=>nil},
#   {:id=>"martin", :key=>"male", :value=>nil}]}
```

Query views by startkey and endkey
```ruby
design_doc = {
 language: "javascript",
 views: {
   people_by_age: {
     map: "function(doc){ if(doc.age) emit(doc.age); }"
   }
 }
}
my_database.create_doc "_design/ages", design_doc

my_database.view("_design/ages", "people_by_age", startkey: 20, endkey: 29)
#=> {:total_rows=>7,
# :offset=>0,
# :rows=>
#  [{:id=>"christina", :key=>22, :value=>nil},
#   {:id=>"james", :key=>23, :value=>nil},
#   {:id=>"nancy", :key=>25, :value=>nil},
#   {:id=>"martin", :key=>29, :value=>nil}]}
```
The above returns documents with age between 20 and 29.

Another example to return documents with age 31 and over
```ruby
my_database.view("_design/ages", "people_by_age", startkey: 31)
#=> {:total_rows=>7,
# :offset=>4,
# :rows=>
#  [{:id=>"lisa", :key=>31, :value=>nil},
#   {:id=>"susan", :key=>35, :value=>nil},
#   {:id=>"kevin", :key=>37, :value=>nil}]}
```

Working with compound startkey and endkey
```ruby
my_database.view("_design/gender_city", "people_by_gender_and_city", startkey: ["female", "bronx", 25].to_s, endkey: ["female", "bronx", 25].to_s)
#=> {:total_rows=>6,
# :offset=>1,
# :rows=>[{:id=>"nancy", :key=>["female", "bronx", 25], :value=>nil}]}
```
###Dynamic Queries
Dynamic queries can be performed on documents using the where() helper method, example to fetch all documents that match the key/value pairs {city: "bronx", gender: "female"}
```ruby
my_database.where(city: "bronx", gender: "female")
#=> [{:_id=>"christina",
#  :_rev=>"1-e9782aa92f7d88eb5dc5e1a878c8e193",
#  :firstname=>"christina",
#  :state=>"new york",
#  :gender=>"female",
#  :city=>"bronx",
#  :age=>22},
# {:_id=>"nancy",
#  :_rev=>"1-44ac471d9e6433eaa6e67607c7a175c9",
#  :firstname=>"nancy",
#  :state=>"new york",
#  :gender=>"female",
#  :city=>"bronx",
#  :age=>25}]
```
To fetch all documents that match the key/value pairs {state: "new york", fullname: ["susan", "Lee"]}
```ruby
my_database.where(state: "new york", fullname: ["susan", "Lee"])
#=> [{:_id=>"susan",
#  :_rev=>"1-11b05eacc247b8541fa6c659f26447de",
#  :firstname=>"susan",
#  :state=>"new york",
#  :gender=>"female",
#  :age=>35,
#  :fullname=>["susan", "Lee"]}]
```
Similar to view(), the where() method also supports options skip, limit, descending. Example to return documents in descending order;
```ruby
my_database.where({city: "bronx", gender: "female"}, descending: true)
#=> [{:_id=>"nancy",
#  :_rev=>"1-44ac471d9e6433eaa6e67607c7a175c9",
#  :firstname=>"nancy",
#  :state=>"new york",
#  :gender=>"female",
#  :city=>"bronx",
#  :age=>25},
# {:_id=>"christina",
#  :_rev=>"1-e9782aa92f7d88eb5dc5e1a878c8e193",
#  :firstname=>"christina",
#  :state=>"new york",
#  :gender=>"female",
#  :city=>"bronx",
#  :age=>22}]
```
Limit to one result
```ruby
my_database.where({city: "bronx", gender: "female"}, limit: 1)
#=> [{:_id=>"christina",
#  :_rev=>"1-e9782aa92f7d88eb5dc5e1a878c8e193",
#  :firstname=>"christina",
#  :state=>"new york",
#  :gender=>"female",
#  :city=>"bronx",
#  :age=>22}]
```
Calling the where() method, for the first time creates a view in the database for provided keys. Subsequent calls to where() will simply query the previously created view and return the documents. For example calling the method below:
```ruby
my_database.where(city: "bronx", gender: "female")
```
Will add the following document to the database,
```javascript
{
   "_id": "_design/city_gender_keys_finder",
   "_rev": "1-41fb3b17c8b99be176928e3ea5588935",
   "language": "javascript",
   "views": {
       "find_by_keys_city_gender": {
           "map": "function(doc){ if(doc.city && doc.gender) emit([doc.city,doc.gender]);}"
       }
   }
}
```
And then query it with:
```
/_design/city_gender_keys_finder/_view/find_by_keys_city_gender?endkey=["bronx", "female"]&include_docs=true&startkey=["bronx", "female"]
```
Subsequent method calls will simply query the view and return the documents. where() is just a convienient helper method.

###Security Object:
To set the security object for the database:
```ruby
security_settings = { admins: {names: ["david"], roles: ["admin"]},
                      readers: {names: ["david"],roles: ["admin"]}
                    }

my_database.security_object = security_settings
#=> {:admins=>{:names=>["david"], :roles=>["admin"]},
# :readers=>{:names=>["david"], :roles=>["admin"]}}
```

To retrieve the security object at anytime:
```ruby
my_database.security_object
#=> {:admins=>{:names=>["david"], :roles=>["admin"]},
# :readers=>{:names=>["david"], :roles=>["admin"]}}
```

###CouchDB Configuration
CouchDB's configuration settings can be set using the set_config() method:
```ruby
config = Leanback::Couchdb.new
config.set_config("section", "option", '"value"')
```
For example to set couchDB's couch_httpd_auth timeout value:
```ruby
config.set_config("couch_httpd_auth", "timeout", '"1600"')
#=> true
```
This sets the CouchDB auth timeout to 1600 seconds.

To retrieve the configuration:
```ruby
config.get_config("couch_httpd_auth", "timeout")
#=> "\"1600\"\n"
```
To delete a configuration:
```ruby
config.delete_config("section", "option")
#=> true
```
A more useful example to add an admin user to couchDB with username and password;
```ruby
config.set_config("admins", username = "james", password = '"abc123"')
#=> true
```
This will add a CouchDB admin with username james, and password abc123. If couchDB was in admin party mode, this would end the party.

##API Specification

```ruby
#JSON result keys are automatically symoblized:
#returns data directly as couchdb returns them unaltered as ruby hash
c = Leanback::Couchdb.new database: xxxxx, username: xxxxx, password: xxxx, address: xxxxx, port: xxxxx

c.create
c.delete
c.create_doc id, {}
c.delete_doc id, rev
c.delete_doc! id
c.update_doc id, {} #hash includes rev
c.edit_doc! id, {}
c.get_doc id

options = { limit: x, skip: x, descending: x}
c.where {}, options

#create a design doc
design_doc = {
 language: "javascript",
 views: {
   get_emails: {
     map: "function(doc){ if(doc.firstname && doc.email) emit(doc.id,{Name: doc.firstname, Email: doc.email}); }"
   }
 }
}
c.create_doc "_design/my_doc", design_doc

#query a view
options = { limit: x, key: x, start_key: x, end_key: x, skip: x, descending: x, include_docs: boolean}
design_doc_name = "_design/my_doc"
view_name = "get_emails"
c.view design_doc_name, view_name, options

security_settings = { admins: {names: ["david"], roles: ["admin"]},
                    readers: {names: ["david"],roles: ["admin"]}
                  }

c.security_object = security_settings

c.security_object
#=> {:admins=>{:names=>["david"], :roles=>["admin"]},
#    :readers=>{:names=>["david"], :roles=>["admin"]}}

c = Leanback::Couchdb.new
c.set_config("couch_httpd_auth", "timeout", '"900"')
c.get_config("couch_httpd_auth", "timeout")
#=> "\"900\"\n"
c.delete_config("section", "option")
```

Target systems jruby-19mode, MRI 1.9.3 - 2.x

Old documentation: [Leanback](http://www.whisperservers.com/leanback/leanback/)


##License
MIT License.

##Copyright

Copyright (c) 2014 Obi Akubue.
