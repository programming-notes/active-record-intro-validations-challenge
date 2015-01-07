require_relative '../spec_helper'

describe "Person" do
  describe "inheritance" do
    it "inherits from ActiveRecord::Base" do
      expect(Person < ActiveRecord::Base).to be true
    end
  end

  describe "associations" do

    before(:all) do
      Person.delete_all
      Person.create(first_name: "Teagan",  last_name: "Hickman")

      teagan = Person.find_by(first_name: "Teagan")

      Dog.delete_all
      dog_1_details = { :name     => "Tenley",
                        :license  => "OH-9384764",
                        :age      => 1,
                        :breed    => "Golden Doodle",
                        :owner_id => teagan.id }

      dog_2_details = { :name     => "Jessica",
                        :license  => "OH-1234009",
                        :age      => 10,
                        :breed    => "Golden Retriever",
                        :owner_id => teagan.id }

      Dog.create([dog_1_details, dog_2_details])


      Rating.delete_all
      Rating.create([
        { coolness: 10, cuteness: 10, dog_id: Dog.first.id, judge_id: teagan.id },
        { coolness: 9,  cuteness: 10, dog_id: Dog.last.id, judge_id: teagan.id }
      ])
    end

    describe "has many ratings" do
      describe "#ratings" do
        it "returns the person's ratings" do
          person = Person.first
          expected_ratings = Rating.where(judge_id: person.id)

          expect(person.ratings).to eq expected_ratings
        end

        it "returns Rating objects" do
          person = Person.first
          ratings = person.ratings

          expect(ratings.all? { |rating| rating.instance_of? Rating }).to be true
        end
      end

      describe "#ratings=" do
        it "changes the person's ratings" do
          person = Person.first
          expect{ person.ratings = [] }.to change{ person.ratings.empty? }.from(false).to(true)
        end
      end
    end

    describe "has many dogs" do
      describe "#dogs" do
        it "returns the person's dogs" do
          person = Person.first
          expected_dogs = Dog.where(owner_id: person.id)

          expect(person.dogs).to eq expected_dogs
        end

        it "returns Rating objects" do
          person = Person.first
          dogs = person.dogs

          expect(dogs.all? { |rating| rating.instance_of? Dog }).to be true
        end
      end

      describe "#dogs=" do
        it "changes the person's dogs" do
          person = Person.first
          expect{ person.dogs = [] }.to change{ person.dogs.empty? }.from(false).to(true)
        end
      end
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
