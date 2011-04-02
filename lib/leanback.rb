require 'rest_client'
require 'yajl'

module Couchdb

  def self.create(database_name)
       set_url
       begin
         response = RestClient.put 'http://' + @url + ':' + @port + '/' + URI.escape(database_name), {:content_type => :json}
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
