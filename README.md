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


options = { limit: x, key: x, start_key: x, end_key: x, skip: x, descending: x}
c.view design_doc_name, viewname, options
c.where hash, options

c.create_design_doc, design_doc_name, path_to_json_doc
c.set_security security_object
c.close_session
```

Target systems jruby-19mode, MRI 1.9.3 - 2.x

##Currently re-writing...



##Goals
* To create a simple Ruby Interface to CouchDB
* Expose the features of CouchDB to the Ruby Lang.,
* Use a minimalist Ruby DSL to access CouchDB
* provide a very easy way to persist and retrieve data

Old documentation: [Leanback](http://www.whisperservers.com/leanback/leanback/)


##License
MIT License.

##Copyright

Copyright (c) 2014 Obi Akubue.
