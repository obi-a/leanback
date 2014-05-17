require 'spec_base'

def db_settings(database_name)
  db_credentials = { username: ENV["COUCHDB_ADMIN_USERNAME"],
                     password: ENV["COUCHDB_ADMIN_PASSWORD"]
                    }
  db_credentials.merge({database: database_name})
end

describe "CouchDB" do
  describe "Create Database" do
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
    it "raises an exception when deleting a database that don't exist" do
      #raises a Leanback::CouchdbException when exception is a couchdb issue
      mydatabase  = Leanback::Couchdb.new db_settings("mydatabase")
      expect{ mydatabase.delete }.to raise_error(Leanback::CouchdbException)
    end
    it "raises an exception when it cannot connect to database" do
      #raises the exception when it is from a non couchdb issue
      a_database  = Leanback::Couchdb.new  database: "adatabase", port: 9999
      expect{ a_database.create }.to raise_error(Errno::ECONNREFUSED)
    end
  end

  describe "Documents" do
    before(:each) do
      @contacts  = Leanback::Couchdb.new db_settings("contacts")
      @contacts.create
    end
    it "creates a document" do
      hash = @contacts.create_doc("linda", firstname: "Linda",
                                           lastname: "Smith",
                                           email: "linda@something.com"
                                  )
      hash.should include(ok: true, id: "linda")
      hash.include?(:rev).should == true
    end
    after(:each) do
      @contacts.delete
    end
  end
end