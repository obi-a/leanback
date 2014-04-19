require 'spec_base.rb'

describe "CouchDB Basic Operations" do
  before(:all) do
    hash = Couchdb.login(username = ENV["COUCHDB_ADMIN_USERNAME"], password = ENV["COUCHDB_ADMIN_PASSWORD"])
    @auth_session =  hash["AuthSession"]
  end

  it "can create and delete a database" do
    #create
    hash = Couchdb.create('employees',@auth_session)
    hash.to_s.should == '{"ok"=>true}'
    hash = Couchdb.all
    hash.include?("employees").should == true
    #delete
    Couchdb.delete 'employees', @auth_session
    hash = Couchdb.all
    hash.include?("employees").should == false
  end

  describe "Documents" do
    before(:all) do
      Couchdb.create('contacts',@auth_session)
    end
    before(:each) do
      @data = {:firstname => 'linda',
                :lastname =>'smith',
                :phone => '212-234-1234',
                :email =>'john@mail.com',
                :twitter => '@linsmith',
                :gender => 'female'
             }
      doc = {:database => 'contacts', :doc_id => 'linda', :data => @data}
      Couchdb.create_doc doc, @auth_session
    end

    it "can view a document and return non-symbolized keys" do
      doc = {:database => 'contacts', :doc_id => 'linda'}
      hash = Couchdb.view doc, @auth_session
      hash["_id"].should == 'linda'
    end

    it "can view a document and return symbolized keys" do
      doc = {:database => 'contacts', :doc_id => 'linda'}
      hash = Couchdb.view(doc,@auth_session, {symbolize_keys: true})
      hash[:_id].should == 'linda'
    end

    it "cannot view a document that doesn't exist" do
      doc = {:database => 'contacts', :doc_id => 'dont_exist'}
      expect {Couchdb.view(doc,@auth_session, {symbolize_keys: true})}.to raise_error(CouchdbException)
    end

    it "can update a document" do
      data = {:age => 24, :lastname => "stevens" }
      doc = { :database => 'contacts', :doc_id => 'linda', :data => data}
      Couchdb.update_doc doc, @auth_session

      doc = {:database => 'contacts', :doc_id => 'linda'}
      hash = Couchdb.view(doc,@auth_session, {symbolize_keys: true})
      hash[:_id].should == 'linda'
      hash[:age].should == 24
      hash[:lastname].should == 'stevens'
    end

    it "cannot update a document that dont exist" do
      data = {:age => 24, :lastname => "stevens" }
      doc = { :database => 'contacts', :doc_id => 'dont_exist', :data => data}
      expect {Couchdb.update_doc(doc, @auth_session)}.to raise_error(CouchdbException)
    end

    it "can find documents that match a single key" do
      #first run creates the view and queries it
      docs = Couchdb.find_by('contacts', {lastname: 'smith'}, @auth_session, symbolize_keys: true)
      docs.first.should include(@data)

      # second queries the view
      docs = Couchdb.find_by('contacts', {lastname: 'smith'}, @auth_session, symbolize_keys: true)
      docs.first.should include(@data)
    end


    it "cannot find documents that match a single key that dont exist" do
      docs = Couchdb.find_by('contacts', {lastname: 'dont_exist'}, @auth_session, symbolize_keys: true)
      docs.should == []
    end

    it "can find documents that match multiple keys" do
      keys = {:gender => 'female', :firstname => 'linda', :lastname => 'smith'}
      docs = Couchdb.where('contacts', keys, @auth_session, symbolize_keys: true)
      docs.first.should include(@data)
    end

    it "returns empty when no document matches all multiple keys" do
      keys = {:gender => 'female', :firstname => 'linda', :lastname => 'smith', :dont_exist => 'dont_exist'}
      docs = Couchdb.where('contacts', keys, @auth_session, symbolize_keys: true)
      docs.should == []
    end

    it "can count documents that match a single key" do
      count = Couchdb.count({:database => 'contacts', :lastname => 'smith'}, @auth_session)
      count.should == 1
      count = Couchdb.count({:database => 'contacts', :lastname => 'dont_exist'}, @auth_session)
      count.should == 0
      count = Couchdb.count({:database => 'contacts', :dont_exist => 'dont_exist'}, @auth_session)
      count.should == 0
    end

    it "can count documents that match multiple keys" do
      keys = {:gender => 'female', :firstname => 'linda', :lastname => 'smith'}
      count = Couchdb.count_by_keys({:database => 'contacts', :keys => keys}, @auth_session)
      count.should == 1
    end

    after(:each) do
      doc = {:database => 'contacts', :doc_id => 'linda'}
      Couchdb.delete_doc doc, @auth_session
    end
    after(:all) do
      Couchdb.delete 'contacts', @auth_session
    end
  end

end