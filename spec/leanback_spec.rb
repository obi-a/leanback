require 'spec_base'

def db_settings(database_name)
  db_credentials = {
    username: ENV["COUCHDB_ADMIN_USERNAME"],
    password: ENV["COUCHDB_ADMIN_PASSWORD"],
    address: ENV["COUCHDB_ADDRESS"] || "http://127.0.0.1"
  }
  db_credentials.merge({database: database_name})
end

describe "CouchDB" do
  describe "#create" do
    it "creates a database" do
      testdb  = Leanback::Couchdb.new db_settings("testdb")
      testdb.create.should == {ok: true}
      testdb.delete.should == {ok: true}
    end
    it "raises an exception when database name is non string" do
      testdb = Leanback::Couchdb.new db_settings(:testdb)
      expect{ testdb.create }.to raise_error(Leanback::InvalidDatabaseName)
    end
    it "raises an exception when creating a database that already exists" do
      #setup
      mytestdb  = Leanback::Couchdb.new db_settings("mytestdb")
      #ceate database
      mytestdb.create
      #try recreating the database that already exists
      expect{ mytestdb.create }.to raise_error(Leanback::CouchdbException)
      #cleanup
      mytestdb.delete
    end
    it "raises an exception when it cannot connect to database" do
      #raises the exception when it is from a non couchdb issue
      a_database  = Leanback::Couchdb.new  database: "adatabase", port: 9999
      expect{ a_database.create }.to raise_error(Errno::ECONNREFUSED)
    end
  end
  describe "#delete" do
    it "deletes a database" do
      testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      testdb.create
      testdb.delete.should include(ok: true)
    end
    it "raises an exception when deleting a database that don't exist" do
      #raises a Leanback::CouchdbException when exception is a couchdb issue
      mydatabase  = Leanback::Couchdb.new db_settings("mydatabase")
      expect{ mydatabase.delete }.to raise_error(Leanback::CouchdbException)
    end
  end
  describe "#create_doc" do
    before(:each) do
      @contacts  = Leanback::Couchdb.new db_settings("contacts")
      @contacts.create
    end
    it "creates a document" do
      hash = @contacts.create_doc("linda", {})
      hash.should include(ok: true, id: "linda")
      hash.include?(:rev).should == true
    end
    it "raises exception for incorrect document id format" do
      expect{ @contacts.create_doc(:linda, {}) }.to raise_error(Leanback::InvalidDocumentID)
    end
    it "raises exception for incorrect document data format" do
      expect{ @contacts.create_doc("david", [])}.to raise_error(Leanback::CouchdbException)
    end
    after(:each) do
      @contacts.delete
    end
  end
  describe "#delete_doc" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
      @doc_id = "john"
      created_doc_hash = @testdb.create_doc @doc_id, {}
      @rev = created_doc_hash[:rev]
    end
    it "deletes a document with revision" do
      deleted_doc_hash = @testdb.delete_doc @doc_id, @rev
      deleted_doc_hash.should include(ok: true, id: @doc_id)
      deleted_doc_hash.include?(:rev).should == true
    end
    it "raises an exception when revision is not found" do
      wrongrev = "5-d5e25dea1ae936b802392bade1de7d93"
      expect{ @testdb.delete_doc @doc_id, wrongrev }.to raise_error(Leanback::CouchdbException)
    end
    it "raises an exception when revision is in wrong format" do
      expect{ @testdb.delete_doc @doc_id, "wrongformat" }.to raise_error(Leanback::CouchdbException)
    end
    it "raises an exception when document cannot be found" do
      expect{ @testdb.delete_doc("not_found", "something") }.to raise_error(Leanback::CouchdbException)
    end
    after(:each) do
      @testdb.delete
    end
  end
  describe "#delete_doc!" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
    end
    it "deletes a doc with no revision" do
      @testdb.create_doc "john", {}
      deleted_doc_hash = @testdb.delete_doc! "john"
      deleted_doc_hash.should include(ok: true, id: "john")
      deleted_doc_hash.include?(:rev).should == true
    end
    it "raises an exception when document cannot be found" do
      expect{ @testdb.delete_doc!("not_found") }.to raise_error(Leanback::CouchdbException)
    end
    after(:each) do
      @testdb.delete
    end
  end
  describe "#get_doc" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
      @testdb.create_doc("james", {lastname: "smith"})
    end
    it "get a document" do
      doc = @testdb.get_doc "james"
      doc.should == {_id: "james", _rev: doc[:_rev], lastname: "smith"}
    end
    it "raises an exception when trying to get document that dont exist" do
      expect{ @testdb.get_doc "dont_exist" }.to raise_error(Leanback::CouchdbException)
    end
    after(:each) do
     @testdb.delete
    end
  end
  describe "#update_doc" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
      doc = @testdb.create_doc("kevin",{firstname: "kevin"})
      @rev = doc[:rev]
      @doc_id = "kevin"
    end
    it "updates a document using a revision" do
      new_firstname = "martin"
      new_doc = @testdb.update_doc @doc_id, _rev: @rev, firstname: new_firstname
      new_doc.should include(ok: true, id: @doc_id)
      doc = @testdb.get_doc @doc_id
      doc[:firstname].should == "martin"
    end
    it "raises an exception when revision is in wrong format" do
      expect{ @testdb.update_doc @doc_id, _rev: "wrongformat", firstname: "mark" }.to raise_error(Leanback::CouchdbException)
    end
    it "raises an exception when revision is not found" do
      wrongrev = "5-d5e25dea1ae936b802392bade1de7d93"
      expect{ @testdb.update_doc @doc_id, _rev: wrongrev, firstname: "mark" }.to raise_error(Leanback::CouchdbException)
    end
    it "creates a new document when provided doc_id is not found" do
      result = @testdb.update_doc "notfound", _rev: @rev, firstname: "mark"
      result.should include(ok: true, id: "notfound" )
      result.include?(:rev).should == true
    end
    after(:each) do
      @testdb.delete
    end
  end
  describe "#edit_doc!" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
      doc = @testdb.create_doc("kevin",{firstname: "kevin"})
      @doc_id = "kevin"
    end
    it "edits a document's existing data" do
      new_firstname = "nancy"
      new_doc = @testdb.edit_doc! @doc_id, firstname: new_firstname
      new_doc.should include(ok: true, id: @doc_id)
      doc = @testdb.get_doc @doc_id
      doc[:firstname].should == "nancy"
    end
    it "edits a document adding new data" do
      lastname = "smith"
      @testdb.edit_doc!(@doc_id, lastname: lastname)
      doc = @testdb.get_doc(@doc_id)
      doc.should include(_id: @doc_id, firstname: "kevin", lastname: lastname)
    end
    it "raises an exception when document cannot be found" do
      expect{ @testdb.edit_doc!("notfound", firstname: "jackson") }.to raise_error(Leanback::CouchdbException)
    end
    after(:each) do
      @testdb.delete
    end
  end
  describe "#security_object" do
    before(:each) do
      @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @testdb.create
      @security_settings = { admins: {names: ["david"], roles: ["admin"]},
                            readers: {names: ["david"],roles: ["admin"]}
                          }
      #sets security object
      @testdb.security_object = @security_settings
    end
    it "sets security object for database" do
      @testdb.security_object.should == @security_settings
    end
    it "sets security object with only admins access control settings" do
      only_admins = { admins: {names: ["david"], roles: ["admin"]}
                          }
      @testdb.security_object = only_admins
      @testdb.security_object.should == only_admins
    end
    it "clears security object" do
      @testdb.security_object = {}
      @testdb.security_object.should == {}
    end
    after(:each) do
      @testdb.delete
    end
  end
  describe "queries" do
    before(:each) do
      @db = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
      @db.create
      @db.create_doc "christina", firstname: "christina", state: "new york", gender: "female", city: "bronx", age: 22
      @db.create_doc "james", firstname: "james", state: "new york", gender: "male", city: "manhattan", age: 23
      @db.create_doc "kevin", firstname: "kevin", state: "new york", gender: "male", city: "bronx", age: 37
      @db.create_doc "lisa", firstname: "lisa", state: "new york", gender: "female", city: "manhattan", age: 31
      @db.create_doc "martin", firstname: "martin", state: "new york", gender: "male", city: "manhattan", age: 29
      @db.create_doc "nancy", firstname: "nancy", state: "new york", gender: "female", city: "bronx", age: 25
      @db.create_doc "susan", firstname: "susan", state: "new york", gender: "female", age: 35, fullname: ["susan", "Lee"]
      design_doc = {
         language: "javascript",
         views: {
           by_gender: {
             map: "function(doc){ if(doc.gender) emit(doc.gender); }"
           }
         }
        }
      @db.create_doc "_design/my_doc", design_doc
    end
      describe "#view" do
        it "can query a permanent view" do
          result = @db.view("_design/my_doc", "by_gender")
          result[:rows].count.should == 7
          result[:rows].first.should include(id: "christina", key: "female")
        end
        it "can query a view by key" do
          result =  @db.view("_design/my_doc", "by_gender", key: '"male"')
          result[:rows].count.should == 3
          result[:rows].first.should include(id: "james", key: "male")
        end
        it "can return query results in descending order" do
          result =  @db.view("_design/my_doc", "by_gender", key: '"male"', descending: true)
          result[:rows].first.should include(id: "martin", key: "male")
        end
        it "can limit the number of documents returned by query" do
          limit =  4
          result = @db.view("_design/my_doc", "by_gender", limit: limit)
          result[:rows].count.should == limit
        end
        it "can skip some docs in a query result" do
          result = @db.view("_design/my_doc", "by_gender", skip: 2)
          result[:rows].count.should == 5
        end
        it "raises an exception when view is not found" do
          expect{ @db.view("_design/my_doc", "not_found") }.to raise_error(Leanback::CouchdbException)
        end
        it "raises an exception when design_doc is not found" do
          expect{ @db.view("_design/not_found", "by_gender") }.to raise_error(Leanback::CouchdbException)
        end
        it "can query views by startkey to endkey" do
          #return only people in their twenties
            design_doc = {
             language: "javascript",
             views: {
               people_by_age: {
                 map: "function(doc){ if(doc.age) emit(doc.age); }"
               }
             }
            }
          @db.create_doc "_design/ages", design_doc
          result = @db.view("_design/ages", "people_by_age", startkey: 20, endkey: 29)
          result[:rows].count.should == 4
          result[:rows].first.should include(id: "christina", key: 22)

          #return only people 31 and above
          result = @db.view("_design/ages", "people_by_age", startkey: 31)
          result[:rows].count.should == 3
          result[:rows].first.should include(id: "lisa", key: 31)
        end
        it "can query startkey to endkey as a string" do
          result = @db.view("_design/my_doc", "by_gender", startkey: '"female"', endkey: '"female"')
          result[:rows].count.should == 4
        end
        it "can query with compound startkey and endkeys" do
          design_doc = {
           language: "javascript",
           views: {
             people_by_gender_and_city: {
               map: "function(doc){ if(doc.gender && doc.city && doc.age) emit([doc.gender, doc.city, doc.age]);}"
             }
           }
          }
         @db.create_doc "_design/gender_city", design_doc
         result = @db.view("_design/gender_city", "people_by_gender_and_city", startkey: ["female", "bronx", 25].to_s, endkey: ["female", "bronx", 25].to_s)
         result[:rows].count.should == 1
         result[:rows].first.should include(id: "nancy", key: ["female", "bronx", 25])
        end
      end
      describe "#where" do
        it "returns documents that match specified attributes" do
          docs = @db.where state: "new york", gender: "female"
          docs.count.should == 4

          new_docs = @db.where state: "new york", fullname: ["susan", "Lee"]
          new_docs.first.should include(_id: "susan")

          other_docs =  @db.where city: "manhattan", age: 29
          other_docs.first.should include(_id: "martin")
        end
        it "returns an empty array when no matching attributes is found" do
          docs = @db.where notfound: "not found", something: "something"
          docs.should == []
        end
      end
    after(:each) do
      @db.delete
    end
  end
  describe "config" do
    before(:each) do
      @c = Leanback::Couchdb.new db_settings("")
    end
    it "sets and gets a config setting" do
      @c.set_config("couch_httpd_auth", "timeout", '"1600"').should == true
      @c.get_config("couch_httpd_auth", "timeout").should ==  "\"1600\"\n"
    end
    it "cannot get a config setting that doesnt exist" do
      expect{ @c.get_config("dont_exist", "dont_exist") }.to raise_error(Leanback::CouchdbException)
    end
    it "deletes a config setting" do
      @c.set_config("section", "option", '"value"').should == true
      @c.delete_config("section", "option").should == true
    end
    it "cannot delete a config setting that don't exist" do
      expect{ @c.delete_config("dont_exist", "dont_exist") }.to raise_error(Leanback::CouchdbException)
    end
    it "config setting's value must be set in correct format" do
      @c.set_config("section", "option", '"value"').should == true
      @c.set_config("section", "option", '"true"').should == true
      @c.set_config("section", "option", '"900"').should == true
      @c.set_config("section", "option", '"value"').should == true
      @c.set_config("section", "option", '"[1]"').should  == true
      @c.delete_config("section", "option").should == true
    end
    it "config setting's value cannot be in the wrong format" do
      expect{ @c.set_config("section", "option", "value") }.to raise_error
    end
  end
end
