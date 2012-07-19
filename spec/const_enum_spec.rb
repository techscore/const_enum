# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ConstEnum do
  describe "const_enum" do
    before do
      @enum1 = const_enum do
        CONST1 1, "label1", "1_opt1", "1_opt2"
        CONST2 2, "label2", "2_opt1", "2_opt2"
        CONST3 3, "label3", "3_opt1", "3_opt2"
        CONST4 4, "label4", "4_opt1", "4_opt2"
        CONST5 5, "label5", "5_opt1", "5_opt2"
        
        def upper_label
          label.upcase
        end
      end
    end
    
    context "constant class methods" do
      it do
        @enum1.should     be_include(1)
        @enum1.should     be_include(2)
        @enum1.should_not be_include(0)
        @enum1.should_not be_include(6)
        @enum1.should_not be_include("1")
        @enum1.label(3).should == "label3"
        @enum1.key(3).should   == :CONST3
        @enum1.values.should   == (1..5).to_a
        @enum1.labels.should   == (1..5).map{|i| "label#{i}"}
        @enum1.keys.should     == (1..5).map{|i| :"CONST#{i}"}
        @enum1.size.should     == 5
      end
    end
    
    context "constant values" do
      it do
        @enum1::CONST1.should == 1
        @enum1::CONST2.should == 2
        @enum1::CONST3.should == 3
        @enum1::CONST4.should == 4
        @enum1::CONST5.should == 5
      end
    end
    
    context "each constants" do
      it do
        @enum1.each_with_index do |obj, i|
          n = i+1
          @enum1[obj.value].should equal obj
          obj.key.should   == :"CONST#{n}"
          obj.value.should == n
          obj.label.should == "label#{n}"
          obj[0].should    == i+1
          obj[1].should    == "label#{n}"
          obj[2].should    == "#{n}_opt1"
          obj[3].should    == "#{n}_opt2"
          obj.upper_label.should == "LABEL#{n}"
          obj.should be_frozen
        end
      end
    end
    
    context "each items" do
      it do
        @enum1.each_key.to_a.should   == @enum1.map(&:key)
        @enum1.each_label.to_a.should == @enum1.map(&:label)
        @enum1.each_value.to_a.should == @enum1.map(&:value)
      end
    end
    
    context "define constant without block" do
      it do
        lambda{@enum1.FAILUER(10, "aaa")}.should raise_error(NoMethodError)
        lambda{@enum1.define_const(:FAILUER, 10, "aaa")}.should raise_error
      end
    end
  end
end
