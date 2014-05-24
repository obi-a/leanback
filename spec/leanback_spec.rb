require 'spec_base'

def db_settings(database_name)
  db_credentials = { username: ENV["COUCHDB_ADMIN_USERNAME"],
                     password: ENV["COUCHDB_ADMIN_PASSWORD"]
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
end
