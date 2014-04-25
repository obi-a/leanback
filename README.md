###Leanback

Simple Ruby Interface to CouchDB.



##Specifications:
4-24-14: New API specifications
```ruby
#JSON result keys are automatically symoblized:
#returns data directly as couchdb returns them
c = Leanback.new {username: xxxxx, password: xxxx, address: xxxxx, port: xxxxx, database: xxxxx, create_db: true }

c.create_db
c.delete_db
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
```

Target systems jruby-19mode, MRI 1.9.3 - 2.x

##Currently re-writing...



##Goals
* To create a simple Ruby Interface to CouchDB
* Expose the features of CouchDB to the Ruby Lang.,
* Use a minimalist Ruby DSL to access CouchDB
* provide a very easy way to persist and retrieve data




##License
MIT License.

##Copyright

Copyright (c) 2014 Obi Akubue.


