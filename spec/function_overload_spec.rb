require 'spec_helper'

class NilClass
  def only_defined_on_nil
  end
end

class Overloaded
  extend Overloadable

  def the_function(a_only_defined_on_nil)
    :one_nil
  end

  def the_function(a_only_defined_on_nil, b_only_defined_on_nil)
    :two_nils
  end

  def the_function(a_reverse)
    :one_reverse
  end

  def the_function(a_only_defined_on_nil, b_split)
    :nil_and_split
  end
end

describe Overloaded do
  describe '#the_function' do
    it 'should acknowledge a single nil argument' do
      Overloaded.new.the_function(nil).should == :one_nil
    end

    it 'should acknowledge two nil arguments' do
      Overloaded.new.the_function(nil, nil).should == :two_nils
    end

    it 'should acknowledge a single argument that reverses' do
      a = []
      a.should respond_to(:reverse) # precondition
      Overloaded.new.the_function(a).should == :one_reverse
    end

    it 'should acknowledge a nil and an argument that splits' do
      a = 'testing'
      a.should respond_to(:split) # precondition
      Overloaded.new.the_function(nil, a).should == :nil_and_split
    end

    it 'should raise an exception with 3 arguments' do
      lambda {
        Overloaded.new.the_function(1,2,3)
      }.should raise_exception(ArgumentError)
    end
  end
end

