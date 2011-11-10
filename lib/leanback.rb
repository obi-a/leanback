require 'rest_client'
require 'yajl'
require 'erb'

class CouchdbException < RuntimeError
   attr :error
   def initialize(error)
    @error = error.values[0]
  end
end

module Couchdb

#login to couchdb
def self.login(username, password)
  set_address
  data = 'name=' + username + '&password=' + password
  begin
   response = RestClient.post 'http://' + @address + ':' + @port + '/_session/', data, {:content_type => 'application/x-www-form-urlencoded'}
   response.cookies
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end
end

#couchdb configuration api
def self.set_config(data,auth_session = nil) 
  section = data[:section]
  key = data[:key] 
  value = data[:value]
  json_data = Yajl::Encoder.encode(value)
  set_address
  begin
   response = RestClient.put 'http://' + @address + ':' + @port + '/_config/' + URI.escape(section) + '/' + URI.escape(key),json_data, {:content_type => :json, :accept => :json}
   hash = Yajl::Parser.parse(response.to_str)
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end
end

def self.delete_config(data,auth_session = nil) 
  section = data[:section]
  key = data[:key] 
  set_address
  begin
   response = RestClient.delete 'http://' + @address + ':' + @port + '/_config/' + URI.escape(section) + '/' + URI.escape(key), {:content_type => :json}
   hash = Yajl::Parser.parse(response.to_str)
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end
end


def self.get_config(data,auth_session = nil) 
  section = data[:section]
  key = data[:key] 
  set_address
  begin
   response = RestClient.get 'http://' + @address + ':' + @port + '/_config/' + URI.escape(section) + '/' + URI.escape(key), {:content_type => :json}
   hash = Yajl::Parser.parse(response.to_str)
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end
end

#create a document 
  def self.create_doc( doc,auth_session = nil)  
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
         raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
       end
  end

  #edit a document
  def self.edit_doc(doc,auth_session = nil)
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
         raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
      end
  end

 #update a doc
 def self.update_doc(doc,auth_session = nil)
      db_name = doc[:database]
      doc_id = doc[:doc_id]
      data = doc[:data]
      doc = {:database => db_name, :doc_id => doc_id}
      options = Couchdb.view doc 
      options = options.merge(data)
      doc = {:database => db_name, :doc_id => doc_id, :data => options}
      edit_doc doc
 end

#delete document
 def self.delete_doc(doc,auth_session = nil)  
   db_name = doc[:database]
   doc_id = doc[:doc_id]
   doc = {:database => db_name, :doc_id => doc_id}
   hash = Couchdb.view doc
   doc = {:database => db_name, :doc_id => doc_id, :rev => hash["_rev"]}
   delete_rev(doc,auth_session)
 end


 #delete a doc by rev#
 def self.delete_rev(doc,auth_session = nil)
   db_name = doc[:database]
   doc_id = doc[:doc_id]
   rev = doc[:rev]
   set_address
   begin 
    response = RestClient.delete 'http://' + @address + ':' + @port + '/' + URI.escape(db_name)  + '/' + URI.escape(doc_id) + '?rev=' + rev, {:content_type => :json}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
     hash = Yajl::Parser.parse(e.response.to_s)
     raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
    end
 end


  #create a database if one with the same name doesn't already exist
  def self.create(database_name,auth_session = nil)
       set_address
       begin
         response = RestClient.put 'http://' + @address + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
         raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
       end
  end

 #delete a database
 def self.delete(database_name,auth_session = nil)
      set_address
       begin
         response = RestClient.delete 'http://' + @address + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
         hash = Yajl::Parser.parse(e.response.to_s)
         raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
       end 
 end

 #return a list of all databases
 def self.all(auth_session = nil)
      set_address
       begin
         response = RestClient.get 'http://' + @address + ':' + @port + '/_all_dbs', {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
       rescue => e
           raise e
       end
 end

##view a document 
def self.view(doc,auth_session = nil)
 set_address
 db_name = doc[:database]
 doc_id = doc[:doc_id]
  begin
   response = RestClient.get 'http://' + @address + ':' + @port + '/' + db_name + '/' + doc_id
   hash = Yajl::Parser.parse(response.to_str)
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
   raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end 
end

#query a permanent view
def self.find(doc,key=nil,auth_session = nil)
 set_address
 db_name = doc[:database]
 design_doc_name = doc[:design_doc]
 view_name = doc[:view]
   begin
    if key == nil
     response = RestClient.get 'http://' + @address + ':' + @port + '/' + db_name + '/_design/' + design_doc_name + '/_view/' + view_name
    else
     response = RestClient.get 'http://' + @address + ':' + @port + '/' + db_name + '/_design/' + design_doc_name + '/_view/' + view_name + URI.escape('?key="' + key + '"')
    end
     hash = Yajl::Parser.parse(response.to_str)
     rows = hash["rows"]
     count = 0
     rows.each do |row|
      rows[count] = row["value"]
      count += 1  
     end
     return rows
   rescue => e
    #puts e.inspect
    hash = Yajl::Parser.parse(e.response.to_s)
    raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
   end
end

#create a design document with views
def self.create_design(doc,auth_session = nil)
 set_address
 db_name = doc[:database]
 design_doc_name = doc[:design_doc]
 json_doc_name = doc[:json_doc]

 begin
  #bind json doc to string
  message_template = ERB.new File.new(json_doc_name).read
  str = message_template.result(binding)
 rescue => e
   raise e
 end

  begin
   
   response = RestClient.put 'http://' + @address + ':' + @port + '/' + db_name + '/_design/' + design_doc_name, str, {:content_type => :json, :accept => :json}
    hash = Yajl::Parser.parse(response.to_str)
  rescue => e
    hash = Yajl::Parser.parse(e.response.to_s)
    raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
  end
end

#Query view, create view on fly if it dosen't already exist
def self.find_on_fly(doc, key = nil,auth_session = nil)  
   db_name = doc[:database]
   design_doc = doc[:design_doc]
   view = doc[:view]
   json_doc = doc[:json_doc]
 
   begin 
      if( key == nil)
       docs = find({:database => db_name, :design_doc => design_doc, :view => view},auth_session = nil) 
      else
       docs = find({:database => db_name, :design_doc => design_doc, :view => view},key,auth_session = nil) 
      end
     rescue CouchdbException => e
        document = { :database => db_name, :design_doc => design_doc, :json_doc => json_doc}
        create_design document,auth_session = nil 
        if( key == nil)
          docs = find({:database => db_name, :design_doc => design_doc, :view => view},auth_session = nil) 
        else
          docs = find({:database => db_name, :design_doc => design_doc, :view => view},key,auth_session = nil) 
        end
      end
    return docs
 end


#add a finder method to the database
#this creates a find by key method
def self.add_finder(options,auth_session = nil)
 set_address 
 db_name = options[:database]
 key = options[:key] 
 design_doc_name = key + '_finder'
 
 view ='{
 "language" : "javascript",
 "views" :{
    "find_by_'+key+'" : {
      "map" : "function(doc){
         if(doc.'+key+')
           emit(doc.'+key+',doc);
        }"
    }
 }
}'

 begin  
  response = RestClient.put 'http://' + @address + ':' + @port + '/' + db_name + '/_design/' + design_doc_name, view, {:content_type => :json, :accept => :json}
 rescue => e
    hash = Yajl::Parser.parse(e.response.to_s)
    raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
 end
end

#find by key 
def self.find_by(options,auth_session = nil)
 set_address 
 db_name = options[:database]
 index =  options.keys[1].to_s
 search_term = options.values[1]
 design_doc_name = index + '_finder'
 view_name = 'find_by_' + index
 
 begin 
  view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
  docs = find view,search_term,auth_session
 rescue CouchdbException => e
    #add a finder/index if one doesn't already exist in the database
    #then find_by_key
    add_finder({:database => db_name, :key => index},auth_session = nil)
    docs = find view,search_term,auth_session
 end
 return docs
end

 #return a list of all docs in the database
def self.docs_from(database_name,auth_session = nil)
  set_address
  begin
         response = RestClient.get 'http://' + @address + ':' + @port + '/' + URI.escape(database_name) + '/_all_docs?include_docs=true', {:content_type => :json}
         hash = Yajl::Parser.parse(response.to_str)
         rows = hash["rows"]
         count = 0 
         rows.each do |row|
            rows[count] = row["doc"]
            count += 1
          end
        return rows
  rescue => e
     hash = Yajl::Parser.parse(e.response.to_s)
     raise CouchdbException.new(hash), "CouchDB: Error - " + hash.values[0] + ". Reason - "  + hash.values[1]
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
