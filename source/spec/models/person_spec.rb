require_relative '../spec_helper'

describe "Person" do
  describe "inheritance" do
    it "inherits from ActiveRecord::Base" do
      expect(Person < ActiveRecord::Base).to be true
    end
  end

  describe "validations" do

    before(:each) do
      Person.delete_all
    end

    let(:valid_details) do
      { :first_name => "John",
        :last_name  => "Smith" }
    end

    it "requires a first name" do
      person = Person.new valid_details.except(:first_name)
      expect(person).to be_invalid
    end

    it "requires a last name" do
      person = Person.new valid_details.except(:last_name)
      expect(person).to be_invalid
    end

  end
end
