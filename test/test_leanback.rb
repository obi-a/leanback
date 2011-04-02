path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

class TestLeanback < Test::Unit::TestCase
  #should "probably rename this file and start testing for real" do
   # flunk "hey buddy, you should probably rename this file and start testing for real"
  #end


  should "create a database if it doesn't already exist" do
 	hash = Couchdb.create 'more_books'
	puts hash.inspect
  end

  should "return error message illegal database name" do
 	hash = Couchdb.create 'more books'
	puts hash.inspect
  end
 
 
end





