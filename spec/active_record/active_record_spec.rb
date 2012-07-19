# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ConstEnum do
  describe "ActiveRecord::Base.const" do
    before do
      User.create(:name=> "user1", :status=> 1, :gender => 'male'  , :role=> 2)
      User.create(:name=> "user2", :status=> 1, :gender => 'female', :role=> 1)
      User.create(:name=> "user3", :status=> 2, :gender => 'male'  , :role=> 1)
      User.create(:name=> "user4", :status=> 2, :gender => 'male'  , :role=> 1)
    end
    
    it do
      active_user   = User.status_active.first
      resigned_user = User.status_resigned.first
      
      active_user.status.should   == User::STATUS::ACTIVE
      resigned_user.status.should == User::STATUS::RESIGNED
      
      active_user.status_label.should   == "Active"
      resigned_user.status_label.should == "Resigned"
      
      active_user.should   be_status_active
      resigned_user.should be_status_resigned
      active_user.should_not   be_status_resigned
      resigned_user.should_not be_status_active
      
      active_user.status = User::STATUS::RESIGNED
      active_user.should     be_status_resigned
      active_user.should     be_was_status_active
      active_user.should_not be_was_status_resigned
      active_user.status_label_was.should == "Active"
      
      male_user   = User.male.first
      female_user = User.female.first
      
      male_user.gender_name.should   == "Male"
      female_user.gender_name.should == "Female"
      
      User::GENDER[male_user.gender  ].symbole_mark.should == "man"
      User::GENDER[female_user.gender].symbole_mark.should == "woman"
      
      User.male.count.should   == 3
      User.female.count.should == 1
      
      male_user.gender = 'femala'
      male_user.should be_invalid
      male_user.gender = 'female'
      male_user.should be_valid
      
      member  = User.scoped_by_role(User::ROLE::MEMBER).first
      admin   = User.scoped_by_role(User::ROLE::ADMIN).first
      lambda{ User.role_admin      }.should raise_error(NoMethodError)
      lambda{ admin.role_label     }.should raise_error(NoMethodError)
      lambda{ admin.role_label_was }.should raise_error(NoMethodError)
      lambda{ admin.role_admin?    }.should raise_error(NoMethodError)
      lambda{ admin.was_role_admin?}.should raise_error(NoMethodError)
    end
  end
end

