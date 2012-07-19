# coding: utf-8
require 'active_record'
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ':memory:')

class User < ActiveRecord::Base
  
  const :STATUS do
    ACTIVE   1
    RESIGNED 2
  end
  
  const :GENDER, :prefix => '', :label_suffix => "_name", :i18n => false, :validation => true, :allow_blank => true do
    MALE   'male',   'Male'   , 'man'
    FEMALE 'female', 'Female' , 'woman'
    
    def symbole_mark
      third
    end
    
  end
  
  const :ROLE, :scope => false, :label_suffix =>false, :predicate => false do
    MEMBER   1
    ADMIN    2
  end
  
end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) {|t| t.string :name; t.integer :status; t.string :gender; t.integer :role}
  end
end

I18n.backend = I18n::Backend::KeyValue.new({})
I18n.backend.store_translations :en, :labels =>{:user =>{:status => { :active => "Active", :resigned => "Resigned" }}}

ActiveRecord::Migration.verbose = false
CreateAllTables.up