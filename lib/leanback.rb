require 'rest_client'

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
      response = RestClient.put "#{@address}:#{@port}/#{URI.escape(@database)}", {content_type: :json},{cookies: {"AuthSession" => auth_session}}
    rescue => e
      handle_error(e)
    end
  private
    def handle_error(exeception)
      exeception.respond_to?('response') ? exeception.response : raise(exeception)
    end
    def auth_session
      return "" if @username.nil? && @password.nil?
      data = "name=#{@username}&password=#{@password}"
      response = RestClient.post "#{@address}:#{@port}/_session/", data, {content_type: 'application/x-www-form-urlencoded'}
      hash = response.cookies
      hash["AuthSession"]
    end
  end
end
