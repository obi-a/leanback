require 'rest_client'
require 'json/pure'

module Leanback
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
        document
      end
    end
  private
    def api_request
      response = yield
      parse_json(response)
    rescue => e
      handle_error(e)
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
    def handle_error(exeception)
      exeception.respond_to?('response') ? parse_json(exeception.response) : raise(exeception)
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
