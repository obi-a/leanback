###Leanback

Simple Ruby Interface to CouchDB.

[![Build Status](https://travis-ci.org/obi-a/leanback.svg?branch=master)](https://travis-ci.org/obi-a/leanback)

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
The means my_database object will perform operations on the couchDB database named "my_database". The above example assumes that the database is in admin party mode, since no username or password was provided.

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
By default, Leanback uses couchDB's default http address and port (http://127.0.0.1:5984), to use a different address and port, include in the initialization:
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

Delete the document with a revision
```ruby
my_database.delete_doc("linda", rev = "1-ff286690ab5b446a727840ce7420843a")
#=> {:ok=>true, :id=>"linda", :rev=>"2-d689d9b5b9f2ded6a2157fc9cc84a00f"}
```
Delete the document without providing a revision
```ruby
my_database.delete_doc!("linda")
#=> {:ok=>true, :id=>"linda", :rev=>"4-5d1a6851ec7562378caa4ce4adef9ee4"}
```
delete_doc! with the bang, first fetches the document, retrieves it's latest revision and then, deletes the document using the latest revision.

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
update_doc replaces the old document with the new data. A revision (_rev) must be provided the data.  The resulting document will be
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
The document is now:
```javascript
{
   "_id": "linda",
   "_rev": "7-e44206dd09d2740171576e5867fff7a1",
   "firstname": "nancy",
   "lastname": "brown",
   "phone": "777-777-7777"
}

```

currently updating...


##API Specification

```ruby
#JSON result keys are automatically symoblized:
#returns data directly as couchdb returns them unaltered as ruby hash
c = Leanback::Couchdb.new database: xxxxx, username: xxxxx, password: xxxx, address: xxxxx, port: xxxxx

c.create
c.delete
c.create_doc id, {data}
c.delete_doc id, rev
c.delete_doc! id
c.update_doc id, {} #hash includes rev
c.edit_doc! id, {}
c.get_doc id

options = { limit: x, skip: x, descending: x}
c.where hash, options

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
