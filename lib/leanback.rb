require 'rest_client'
require 'yajl'
require 'erb'

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

##view a document 
def self.view(doc)
 set_address
 db_name = doc[:database]
 doc_id = doc[:doc_id]
  begin
   response = RestClient.get 'http://' + @address + ':' + @port + '/' + db_name + '/' + doc_id
   hash = Yajl::Parser.parse(response.to_str)
  rescue => e
   hash = Yajl::Parser.parse(e.response.to_s)
 end 
end

#query a permanent view
def self.find(doc,key=nil)
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
   end
end

#create a design document with views
def self.create_design(doc)
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
  end
end

#add a finder method to the database
#this creates a find by key method
def self.add_finder(options)
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
 end
end

#find by key 
def self.find_by(options)
 set_address 
 db_name = options[:database]
 index =  options.keys[1].to_s
 search_term = options.values[1]
 design_doc_name = index + '_finder'
 view_name = 'find_by_' + index
  
 view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
 find view,search_term
end

 #return a list of all docs in the database
def self.docs_from(database_name)
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
