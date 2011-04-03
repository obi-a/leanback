path = File.expand_path(File.dirname(__FILE__))

require path + "/helper.rb"

class TestLeanback < Test::Unit::TestCase
  #should "probably rename this file and start testing for real" do
   # flunk "hey buddy, you should probably rename this file and start testing for real"
  #end


  #should "create a database if it doesn't already exist" do
 #	hash = Couchdb.create 'more_books'
#	puts hash.inspect
 # end

  #should "return error message illegal database name" do
 #	hash = Couchdb.create 'more books'
#	puts hash.inspect
 # end

  #should "return a display a list of all databases" do
   #   databases = Couchdb.all_dbs
    #    databases.each do |db_name| 
     #      puts db_name
      #  end
   #end

  # should "delete a database" do 
   #    hash = Couchdb.delete 'more_books'
    #   puts hash.inspect
   #end

  should "create a document" do 
         data = {:firstname => 'Mary', :lastname =>'smith', :phone => '212-234-1234',:email =>'john@mail.com'}
         doc = {:database => 'contacts', :doc_id => 'Mary', :data => data}
         hash = Document.create doc
         puts hash.inspect    
  end

 #should "edit a document" do 
  #       data = {:firstname => 'john', :lastname =>'smith', :email => 'john@mail.com',:gender=>'male', :_rev=>'2-57e1f041838e19d91191e391970d16ce'}
   #      doc = {:database => 'contacts', :doc_id => 'john', :data => data}
    #     hash = Document.edit doc
     #    puts hash.inspect    
  #end

   should "delete a document" do 
         doc = {:database => 'contacts', :doc_id => 'john', :rev => '3-be02e80490f8e9e610d9a9e33d752316'}
         Document.delete doc
         puts hash.inspect
   end
  
end





