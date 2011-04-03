require 'rest_client'
require 'yajl'

module Document
  
  #create a document 
  def self.create( doc)  
      
      db_name =  doc[:database]
      doc_id = doc[:doc_id]
      data = doc[:data]
      
      json_data = Yajl::Encoder.encode(data)
      
      set_url

      begin
         response = RestClient.put 'http://' + @url + ':' + @port + '/' + URI.escape(db_name) + '/' + URI.escape(doc_id),json_data, {:content_type => :json, :accept => :json}
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
      
      set_url

      begin
        response = RestClient.put 'http://' + @url + ':' + @port + '/' + URI.escape(db_name) + '/' + URI.escape(doc_id), json_data, {:content_type => :json, :accept => :json}
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
   set_url
   begin 
    response = RestClient.delete 'http://' + @url + ':' + @port + '/' + URI.escape(db_name)  + '/' + URI.escape(doc_id) + '?rev=' + rev, {:content_type => :json}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
     hash = Yajl::Parser.parse(e.response.to_s)
    end
   
 end

   class << self
       attr_accessor :url 
       attr_accessor :port 
     
     def set_url()
      if @url == nil && port == nil
         @url = 'localhost'
         @port = '5984'
      end 
     end
  end
end

module Couchdb
  #create a database if one with the same name doesn't already exist
  def self.create(database_name)
       set_url
       begin
         response = RestClient.put 'http://' + @url + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
       end
  end
  

 #delete a database
 def self.delete(database_name)
      set_url
       begin
         response = RestClient.delete 'http://' + @url + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
       end 
 end

 #return a list of all databases
 def self.all_dbs
      set_url
       begin
         response = RestClient.get 'http://' + @url + ':' + @port + '/_all_dbs', {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
           raise e
       end
 end


 class << self
       attr_accessor :url 
       attr_accessor :port 
     
     def set_url()
      if @url == nil && port == nil
         @url = 'localhost'
         @port = '5984'
      end 
     end
  end
end
