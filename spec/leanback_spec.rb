require 'spec_base'

def db_settings(database_name)
  db_credentials = { username: ENV["COUCHDB_ADMIN_USERNAME"],
                     password: ENV["COUCHDB_ADMIN_PASSWORD"]
                    }
  db_credentials.merge({database: database_name})
end

describe "CouchDB" do
  describe "Create database" do
    it "creates a database and deletes a database" do
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
  describe "Delete Database" do
    it "should delete a database" do
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
  describe "Create Documents" do
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
    describe "Delete Document" do
      before(:each) do
        @testdb  = Leanback::Couchdb.new db_settings("testdb#{Time.now.to_i}")
        @testdb.create
      end
      it "deletes a document with revision" do
        created_doc_hash = @testdb.create_doc "john", {}
        deleted_doc_hash = @testdb.delete_doc "john", created_doc_hash[:rev]
        deleted_doc_hash.should include(ok: true, id: "john")
        deleted_doc_hash.include?(:rev).should == true
      end
      it "deletes a doc with no revision" do
        @testdb.create_doc "john", {}
        deleted_doc_hash = @testdb.delete_doc! "john"
        deleted_doc_hash.should include(ok: true, id: "john")
        deleted_doc_hash.include?(:rev).should == true
      end
      it "raises an exception when document cannot be found" do
        expect{ @testdb.delete_doc("not_found", "something") }.to raise_error(Leanback::CouchdbException)
        expect{ @testdb.delete_doc!("not_found") }.to raise_error(Leanback::CouchdbException)
      end
      after(:each) do
        @testdb.delete
      end
    end
    describe "Get Document" do
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
  end
end
