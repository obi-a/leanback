###Leanback

Simple Ruby Interface to CouchDB.



##Specifications for v0.5.0:
4-24-14: New API specifications
```ruby
#JSON result keys are automatically symoblized:
#returns data directly as couchdb returns them unaltered as ruby hash
c = Leanback::Couchdb.new database_name, username: xxxxx, password: xxxx, address: xxxxx, port: xxxxx

c.create
c.delete
c.create_doc id, {data}
c.delete_doc id, rev
c.delete_doc! id
c.edit_doc id, rev, {}
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
options = { limit: x, key: x, start_key: x, end_key: x, skip: x, descending: x}
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
```

Target systems jruby-19mode, MRI 1.9.3 - 2.x

##Currently re-writing...

Old documentation: [Leanback](http://www.whisperservers.com/leanback/leanback/)


##License
MIT License.

##Copyright

Copyright (c) 2014 Obi Akubue.
