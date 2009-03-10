require File.dirname(__FILE__) + '/spec_helper'

context "The model" do
  setup do 
    @person = Person.create(:name => 'Jocke', :age => 21)
  end

  it "should respond to paged" do
    @person.should respond_to(:paged)
  end
end

