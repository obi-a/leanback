require 'rest_client'
require 'json/pure'
require 'active_support/all'

module Leanback
  class CouchdbException < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
    end
  end
  class Couchdb
    attr_reader :address
    attr_reader :port
    attr_reader :username
    attr_reader :password
    attr_reader :database
    def initialize(database, args = {})
      raise "Invalid database name: #{database.inspect}"  unless database.is_a? String
      @database = database
      @address = args.fetch(:address, 'http://127.0.0.1')
      @port = args.fetch(:port, '5984')
      @username = args.fetch(:username, nil)
      @password = args.fetch(:password, nil)
    end
    def create
     api_request { RestClient.put "#{address_port}/#{db_uri}", content_type, cookies }
    end
    def delete
      api_request { RestClient.delete "#{address_port}/#{db_uri}", cookies }
    end
    def create_doc(doc_id, doc)
      api_request { RestClient.put "#{address_port}/#{db_uri}/#{doc_uri(doc_id)}", generate_json(doc), cookies }
    end
    def delete_doc(doc_id, rev)
      api_request {  RestClient.delete "#{address_port}/#{db_uri}/#{doc_uri(doc_id)}?rev=#{rev}", cookies }
    end
    def delete_doc!(doc_id)
      document = get_doc(doc_id)
      (document[:_id] && document[:_rev]) ? delete_doc(document[:_id], document[:_rev]) : document
    end
    def get_doc(doc_id)
      api_request { RestClient.get "#{address_port}/#{@database}/#{doc_id}", cookies }
    end
    def edit_doc(doc_id, data)
      api_request { RestClient.put "#{address_port}/#{db_uri}/#{doc_uri(doc_id)}", generate_json(data), cookies }
    end
    def edit_doc!(doc_id, data)
      document = get_doc(doc_id)
      if (document[:_id] && document[:_rev])
        document_with_rev = document.merge(data)
        edit_doc(doc_id, document_with_rev)
      else
        #raise unknownerror
      end
    end
    def view(design_doc_name, view_name, options = {})
      api_request { RestClient.get "#{address_port}/#{db_uri}/_design/#{URI.escape(design_doc_name)}/_view/#{URI.escape(view_name)}?#{options.to_query}", cookies }
    end
    def where(hash, options = {})
      search_term = hash.values
      index = hash.keys.join("_")
      new_options = options.merge({startkey: search_term, endkey: search_term})
      view!("#{index}_keys_finder", "find_by_keys_#{index}", new_options)
    rescue CouchdbException => e
      add_multiple_finder(hash.keys)
      view!("#{index}_keys_finder", "find_by_keys_#{index}", new_options)
    end
    def view!(design_doc_name, view_name, options = {})
      result = view(design_doc_name, view_name, options)
      rows = result[:rows]
      rows.map { |row| row[:value] }
    end
  private
    def add_multiple_finder(keys)
      view_name = keys.join("_")
      condition = keys.join(" && doc.")
      design_doc_name = "#{view_name}_keys_finder"
      design_doc = {
                      language: "javascript",
                      views: {
                                "find_by_keys_#{view_name}" => {
                                  map: "function(doc){ if(doc.#{condition}) emit([doc.id],doc);}"
                                }
                             }
                   }
      create_doc "_design/#{design_doc_name}", design_doc
    end
    def api_request
      response = yield
      parse_json(response)
    rescue => e
      raise_error(e)
    end
    def doc_uri(doc_id)
      URI.escape(doc_id)
    end
    def db_uri
      URI.escape(@database)
    end
    def content_type
      {content_type: :json}
    end
    def cookies
      {cookies: {"AuthSession" => auth_session}}
    end
    def address_port
      "#{@address}:#{@port}"
    end
    def parse_json(json_doc)
      JSON.parse(json_doc, symbolize_names: true)
    end
    def generate_json(data)
      JSON.generate(data)
    end
    def raise_error(exeception)
      if exeception.respond_to?('response')
        response = parse_json(exeception.response)
        raise(CouchdbException.new(response), response)
      else
        raise(exeception)
      end
    end
    def auth_session
      return "" if @username.nil? && @password.nil?
      data = "name=#{@username}&password=#{@password}"
      response = RestClient.post "#{@address}:#{@port}/_session/", data, {content_type: 'application/x-www-form-urlencoded'}
      hash = response.cookies
      hash["AuthSession"]
    rescue => e
      handle_error(e)
    end
  end
end
