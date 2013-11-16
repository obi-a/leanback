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
  def self.couch_error(e)
    raise e if e.is_a? OpenSSL::SSL::SSLError
    hash = Yajl::Parser.parse(e.response.to_s)
    raise CouchdbException.new(hash), "CouchDB: Error - #{hash.values[0]}. Reason - #{hash.values[1]}" 
  end

  def self.salt
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    salt  =  (0..50).map{ o[rand(o.length)]  }.join; 
  end

  #change non-admin user password
  def self.change_password(username, new_password,auth_session = "")
    salty = salt()
    password_sha = Digest::SHA1.hexdigest(new_password + salty) 
    user_id = 'org.couchdb.user:' + username
    data = {"salt" => salty,"password_sha" => password_sha}
    doc = { :database => '_users', :doc_id => user_id, :data => data}   
    update_doc doc,auth_session
  end

  #add a new user 
  def self.add_user(user, auth_session="")
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    salt  =  (0..50).map{ o[rand(o.length)]  }.join; 
    new_user = {:username => user[:username], :password => user[:password], :roles => user[:roles], :salt => salt}
    create_user(new_user,auth_session)
  end

  #create a new user 
  def self.create_user(user,auth_session= "")
    password_sha = Digest::SHA1.hexdigest(user[:password] + user[:salt])              
  
    user_hash = { :type => "user",
                  :name => user[:username],
                  :password_sha => password_sha,
                  :salt => user[:salt],
                  :roles => user[:roles]
                 }
   
    str = Yajl::Encoder.encode(user_hash)
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/_users/org.couchdb.user:#{URI.escape(user[:username])}", str,{:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end 

  end

  #add security object
  def self.set_security(db_name, data,auth_session="")
    security_data = Yajl::Encoder.encode(data)
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/#{URI.escape(db_name)}/_security/",security_data, {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end 
  end
  
  #get security object
  def self.get_security(db_name, auth_session="")
    set_address
    begin
      response = RestClient.get "#{@address}:#{@port}/#{URI.escape(db_name)}/_security/", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end 
  end

  #login to couchdb
  def self.login(username, password)
    set_address
    data = "name=#{username}&password=#{password}"
    begin
      response = RestClient.post "#{@address}:#{@port}/_session/", data, {:content_type => 'application/x-www-form-urlencoded'}
      response.cookies
    rescue => e
      couch_error(e)
    end
  end

  #couchdb configuration api
  def self.set_config(data,auth_session = "") 
    section = data[:section]
    key = data[:key] 
    value = data[:value]
    json_data = Yajl::Encoder.encode(value)
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/_config/#{URI.escape(section)}/#{URI.escape(key)}",json_data, {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

  def self.delete_config(data,auth_session = "") 
    section = data[:section]
    key = data[:key] 
    set_address
    begin
      response = RestClient.delete "#{@address}:#{@port}/_config/#{URI.escape(section)}/#{URI.escape(key)}", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end


  def self.get_config(data,auth_session = "") 
    section = data[:section]
    key = data[:key] 
    set_address
    begin
      response = RestClient.get "#{@address}:#{@port}/_config/#{URI.escape(section)}/#{URI.escape(key)}", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

  #create a document 
  def self.create_doc( doc,auth_session = "")  
    db_name =  doc[:database]
    doc_id = doc[:doc_id]
    data = doc[:data]
    json_data = Yajl::Encoder.encode(data)
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/#{URI.escape(db_name)}/#{URI.escape(doc_id)}",json_data, {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

  #edit a document
  def self.edit_doc(doc,auth_session = "")
    db_name = doc[:database]
    doc_id = doc[:doc_id]
    data = doc[:data]
    json_data = Yajl::Encoder.encode(data)
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/#{URI.escape(db_name)}/#{URI.escape(doc_id)}", json_data, {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

 #update a doc
  def self.update_doc(doc,auth_session = "")
    db_name = doc[:database]
    doc_id = doc[:doc_id]
    data = doc[:data]
    doc = {:database => db_name, :doc_id => doc_id}
    options = Couchdb.view doc,auth_session 
    options = options.merge(data)
    doc = {:database => db_name, :doc_id => doc_id, :data => options}
    edit_doc doc,auth_session
  end

  #delete document
  def self.delete_doc(doc,auth_session = "")  
    db_name = doc[:database]
    doc_id = doc[:doc_id]
    doc = {:database => db_name, :doc_id => doc_id}
    hash = Couchdb.view doc,auth_session
    doc = {:database => db_name, :doc_id => doc_id, :rev => hash["_rev"]}
    delete_rev(doc,auth_session)
  end


  #delete a doc by rev#
  def self.delete_rev(doc,auth_session = "")
    db_name = doc[:database]
    doc_id = doc[:doc_id]
    rev = doc[:rev]
    set_address
    begin 
      response = RestClient.delete  "#{@address}:#{@port}/#{URI.escape(db_name)}/#{URI.escape(doc_id)}?rev=#{rev}", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end


  #create a database if one with the same name doesn't already exist
  def self.create(database_name,auth_session = "")
    set_address
    begin
      response = RestClient.put "#{@address}:#{@port}/#{URI.escape(database_name)}", {:content_type => :json},{:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

  #delete a database
  def self.delete(database_name,auth_session = "")
    set_address
    begin
      response = RestClient.delete "#{@address}:#{@port}/#{URI.escape(database_name)}", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end 
  end

  #return a list of all databases
  def self.all(auth_session = "")
    set_address
    begin
      response = RestClient.get "#{@address}:#{@port}/_all_dbs", {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      raise e
    end
  end

  ##view a document 
  def self.view(doc,auth_session = "", options = {})
    set_address
    db_name = doc[:database]
    doc_id = doc[:doc_id]
    begin
      response = RestClient.get "#{@address}:#{@port}/#{db_name}/#{doc_id}",{:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str, symbolize_keys(options))
    rescue => e
      couch_error(e)
    end 
  end

  def self.get_params(options)
    params = ""
    if options.has_key?(:startkey)
      if options[:startkey].is_a? String
        params = 'startkey="' + options[:startkey] + '"'
      else
        params = 'startkey=' + options[:startkey].to_s # for complex keys
      end
    end
    if options.has_key?(:endkey)
      if options[:endkey].is_a? String
        params = params + '&endkey="' + options[:endkey] + '"'
      else
        params = params + '&endkey=' + options[:endkey].to_s  #for complex keys
      end
    end

    if options.has_key?(:limit)
      params = params + "&" + "limit=" + options[:limit].to_s
    end

    if options.has_key?(:skip)
      params = params + "&" + "skip=" + options[:skip].to_s
    end

    if options.has_key?(:descending)
      params = params + "&" + "descending=true"
    end

    return params
  end


  #query a permanent view
  def self.find(doc,auth_session = "", key=nil, options = {})
    set_address
    db_name = doc[:database]
    design_doc_name = doc[:design_doc]
    view_name = doc[:view]
    params = get_params(options)
   
    begin
      if key == nil
        response = RestClient.get "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}/_view/#{view_name}?#{URI.escape(params)}",{:cookies => {"AuthSession" => auth_session}}
      else
        key = URI.escape('?key="' + key + '"')
        response = RestClient.get "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}/_view/#{view_name}#{key}&#{URI.escape(params)}" ,{:cookies => {"AuthSession" => auth_session}}
      end
      hash = Yajl::Parser.parse(response.to_str, symbolize_keys(options))
      data = []
      rows = hash["rows"] unless hash["rows"].nil?
      rows = hash[:rows] unless hash[:rows].nil?
      rows.each do |row|
        value = row["value"] unless row["value"].nil?
        value = row[:value] unless row[:value].nil?
        data << value 
      end
      return data
     rescue => e
       couch_error(e)
     end
  end

  #create a design document with views
  def self.create_design(doc,auth_session = "")
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
      response = RestClient.put "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}", str, {:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
    rescue => e
      couch_error(e)
    end
  end

  #Query view, create view on fly if it dosen't already exist
  def self.find_on_fly(doc,auth_session = "",key = nil, options = {})  
    db_name = doc[:database]
    design_doc = doc[:design_doc]
    view = doc[:view]
    json_doc = doc[:json_doc]
    query_info = {:database => db_name, :design_doc => design_doc, :view => view}
    begin 
      if( key == nil)
        docs = find(query_info,auth_session,key=nil,options) 
      else
        docs = find(query_info,auth_session,key,options) 
      end
    rescue CouchdbException => e
      document = { :database => db_name, :design_doc => design_doc, :json_doc => json_doc}
      create_design document,auth_session
      if( key == nil)
        docs = find(query_info,auth_session,key=nil,options) 
      else
        docs = find(query_info,auth_session,key,options) 
      end
   end
     return docs
  end


  #add a finder method to the database
  #this creates a find by key method
  def self.add_finder(options,auth_session = "")
    set_address 
    db_name = options[:database]
    key = options[:key] 
    design_doc_name = key + '_finder'
 
    view ='{
    "language" : "javascript",
    "views" :{
       "find_by_'+key+'" : {
         "map" : "function(doc){ if(doc.'+key+') emit(doc.'+key+',doc);}"
       }
    }
   }'

   begin  
     response = RestClient.put "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}", view, {:cookies => {"AuthSession" => auth_session}}
    rescue => e
      couch_error(e)
    end
  end

  #add a multiple finder method to the database
  #this creates a find by keys method
  def self.add_multiple_finder(options,auth_session = "")
    set_address 
    db_name = options[:database]
    keys = options[:keys]
    view_name = keys.join("_")
    key = keys.join(",doc.")
    condition = keys.join(" && doc.")
    design_doc_name = "#{view_name}_keys_finder"

    view = '{
    "language" : "javascript",
    "views" :{
       "find_by_keys_'+view_name+'" : {
         "map" : "function(doc){ if(doc.'+condition+') emit([doc.'+key+'],doc);}"
       }
     }
    }' 

    begin  
      response = RestClient.put "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}", view, {:cookies => {"AuthSession" => auth_session}}
    rescue => e
      couch_error(e)
    end
  end

  #add a multiple counter method to the database
  #this creates a count by keys method
  def self.add_multiple_counter(options,auth_session = "")
    set_address 
    db_name = options[:database]
    keys = options[:keys]
    view_name = keys.join("_")
    key = keys.join(",doc.")
    condition = keys.join(" && doc.")
    design_doc_name = "#{view_name}_keys_counter"
    view = '{
    "language" : "javascript",
    "views" :{
    "count_by_keys_'+view_name+'" : {
      "map" : "function(doc){ if(doc.'+condition+') emit([doc.'+key+'],null);}", "reduce": "_count"
         }
       }
     }' 

    begin  
      response = RestClient.put "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}", view, {:cookies => {"AuthSession" => auth_session}}
    rescue => e
      couch_error(e)
    end
  end

  #add a counter method to the database
  #this creates a count method that counts documents by key
  def self.add_counter(options,auth_session = "")
    set_address 
    db_name = options[:database]
    key = options[:key] 
    design_doc_name = key + '_counter'
 
    view ='{
    "language" : "javascript",
    "views" :{
       "count_'+key+'" : {
          "map" : "function(doc){ if(doc.'+key+') emit(doc.'+key+',null);}", "reduce": "_count"   
              }
           }
        }'

    begin  
      response = RestClient.put "#{@address}:#{@port}/#{db_name}/_design/#{design_doc_name}", view, {:cookies => {"AuthSession" => auth_session}}
    rescue => e
      couch_error(e)
    end
  end

  #count by key 
  def self.count(options,auth_session = "")
    set_address 
    db_name = options[:database]
    index =  options.keys[1].to_s
    search_term = options.values[1]
    design_doc_name = "#{index}_counter"
    view_name = "count_#{index}"
 
    begin 
      view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
      docs = find view,auth_session,search_term
    rescue CouchdbException => e
      #add a counter index if one doesn't already exist in the database
      #then count_by_key
      add_counter({:database => db_name, :key => index},auth_session)
      docs = find view,auth_session,search_term
    end
      count = docs[0]
    return count.to_i
  end

  #count by keys
  #example: 
  #hash = {:firstname =>'john', :gender => 'male' }
  #Couchdb.count_by_keys({:database => 'contacts', :keys => hash},auth_session)
  def self.count_by_keys(options,auth_session = "", params = {})
    set_address
    db_name = options[:database]
    keys = []
    search_term = []
    hash = options[:keys]

    hash.each do |k,v|
      keys << k
      search_term << v
    end
   index = keys.join("_")
   design_doc_name = "#{index}_keys_counter"
   view_name = "count_by_keys_#{index}"
   params[:startkey] = search_term
   params[:endkey] = search_term
 
   begin 
     view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
     docs = find view,auth_session,key=nil,params
   rescue CouchdbException => e
     #add a finder/index if one doesn't already exist in the database
     #then find_by_keys
     add_multiple_counter({:database => db_name, :keys => keys},auth_session)
     docs = find view,auth_session,key=nil,params
   end
     count = docs[0]
     return count.to_i
  end

  #find by key 
  def self.find_by(options,auth_session = "", params = {})
    set_address 
    db_name = options[:database]
    index =  options.keys[1].to_s
    search_term = options.values[1]
    design_doc_name = "#{index}_finder"
    view_name = "find_by_#{index}"
 
    begin 
      view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
      docs = find view,auth_session,search_term,params
    rescue CouchdbException => e
      #add a finder/index if one doesn't already exist in the database
      #then find_by_key
      add_finder({:database => db_name, :key => index},auth_session)
      docs = find view,auth_session,search_term,params
    end
    return docs
  end

  #find by keys
  #example: 
  #hash = {:firstname =>'john', :gender => 'male' }
  #Couchdb.find_by_keys({:database => 'contacts', :keys => hash},auth_session)
  def self.find_by_keys(options,auth_session = "", params = {})
    set_address
    db_name = options[:database]
    keys = []
    search_term = []
    hash = options[:keys]

    hash.each do |k,v|
      keys << k
      search_term << v
    end
    index = keys.join("_")
    design_doc_name = "#{index}_keys_finder"
    view_name = "find_by_keys_#{index}"
    params[:startkey] = search_term
    params[:endkey] = search_term
 
    begin 
      view = { :database => db_name, :design_doc => design_doc_name, :view => view_name}
      docs = find view,auth_session,key=nil,params
    rescue CouchdbException => e
      #add a finder/index if one doesn't already exist in the database
      #then find_by_keys
      add_multiple_finder({:database => db_name, :keys => keys},auth_session)
      docs = find view,auth_session,key=nil,params
    end
    return docs
  end

  #return a list of all docs in the database
  def self.docs_from(database_name,auth_session = "")
    set_address
    begin
      response = RestClient.get "#{@address}:#{@port}/#{URI.escape(database_name)}/_all_docs?include_docs=true",{:cookies => {"AuthSession" => auth_session}}
      hash = Yajl::Parser.parse(response.to_str)
      rows = hash["rows"]
      count = 0 
      rows.each do |row|
        rows[count] = row["doc"]
        count += 1
      end
      return rows
    rescue => e
      couch_error(e)
    end  
  end
  
  def self.symbolize_keys(options)
    return {symbolize_keys: true} if options[:symbolize_keys]
    return {}
  end

  private_class_method :symbolize_keys

  class << self
    attr_accessor :address 
    attr_accessor :port 

    def set_address()
      if @address == nil 
        @address = 'http://127.0.0.1'
      end
      if @port == nil
        @port = '5984'
      end 
    end
  end
end
