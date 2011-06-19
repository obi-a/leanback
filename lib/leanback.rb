require 'rest_client'
require 'yajl'

module Document
  
  #create a document 
  def self.create( doc)  
      db_name =  doc[:database]
      doc_id = doc[:doc_id]
      data = doc[:data]
      json_data = Yajl::Encoder.encode(data)
      set_address
      begin
         response = RestClient.put 'http://' + @address + ':' + @port + '/' + URI.escape(db_name) + '/' + URI.escape(doc_id),json_data, {:content_type => :json, :accept => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
       end
  end

  #edit a document
  def self.edit(doc)
      db_name = doc[:database]
      doc_id = doc[:doc_id]
      data = doc[:data]
      json_data = Yajl::Encoder.encode(data)
      set_address
      begin
        response = RestClient.put 'http://' + @address + ':' + @port + '/' + URI.escape(db_name) + '/' + URI.escape(doc_id), json_data, {:content_type => :json, :accept => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
      end
  end

 #delete a doc
 def self.delete(doc)
   db_name = doc[:database]
   doc_id = doc[:doc_id]
   rev = doc[:rev]
   set_address
   begin 
    response = RestClient.delete 'http://' + @address + ':' + @port + '/' + URI.escape(db_name)  + '/' + URI.escape(doc_id) + '?rev=' + rev, {:content_type => :json}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
     hash = Yajl::Parser.parse(e.response.to_s)
    end
 end

   class << self
       attr_accessor :address 
       attr_accessor :port 
     def set_address
      if @address == nil && port == nil
         @address = '127.0.0.1'
         @port = '5984'
      end 
     end
  end
end

module Couchdb
  #create a database if one with the same name doesn't already exist
  def self.create(database_name)
       set_address
       begin
         response = RestClient.put 'http://' + @address + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
       end
  end
  

 #delete a database
 def self.delete(database_name)
      set_address
       begin
         response = RestClient.delete 'http://' + @address + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
       end 
 end

 #return a list of all databases
 def self.all
      set_address
       begin
         response = RestClient.get 'http://' + @address + ':' + @port + '/_all_dbs', {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
           raise e
       end
 end

##find a document by _id
def self.find(doc)
 set_address
 db_name = doc[:database]
 doc_id = doc[:doc_id]
  begin
   response = RestClient.get 'http://' + @address + ':' + @port + '/' + db_name + '/' + doc_id
   hash = Yajl::Parser.parse(response.to_str)
   #puts hash.inspect
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   #puts hash.inspect
 end 
end

 #return a list of all docs in the database
def self.docs_from(database_name)
  set_address
  begin
         response = RestClient.get 'http://' + @address + ':' + @port + '/' + URI.escape(database_name) + '/_all_docs?include_docs=true', {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
         rows = hash["rows"]
         only_rows = []
         count = 0 
         rows.each do |row|
            only_rows[count] = row["doc"]
            count = count + 1
          end
        return only_rows
  rescue => e
     hash = Yajl::Parser.parse(e.response.to_s)
  end  
end


 class << self
       attr_accessor :address 
       attr_accessor :port 
     def set_address()
      if @address == nil && port == nil
         @address = '127.0.0.1'
         @port = '5984'
      end 
     end
  end
end
