require_relative '../spec_helper'

describe "Rating" do
  describe "inheritance" do
    it "inherits from ActiveRecord::Base" do
      expect(Rating < ActiveRecord::Base).to be true
    end
  end

  describe "associations" do

    before(:all) do
      Person.delete_all
      teagan = Person.create(first_name: "Teagan",  last_name: "Hickman")

      Dog.delete_all
      dog = Dog.create( { :name     => "Tenley",
                          :license  => "OH-9384764",
                          :age      => 1,
                          :breed    => "Golden Doodle",
                          :owner_id => teagan.id } )

      Rating.delete_all
      Rating.create({ coolness: 5, cuteness: 6, judge_id: teagan.id, dog_id: dog.id })
    end

    describe "belongs to dog" do
      describe "#dog" do
        it "returns the rating's dog" do
          rating = Rating.first
          expected_dog = Dog.find(rating.dog_id)

          expect(rating.dog).to eq expected_dog
        end

        it "returns a Dog object" do
          rating = Rating.first
          expect(rating.dog).to be_instance_of Dog
        end
      end

      describe "#dog=" do
        it "sets dog_id" do
          rating = Rating.new
          dog = Dog.first

          expect{ rating.dog = dog }.to change{ rating.dog_id }.from(nil).to(dog.id)
        end
      end
    end

    describe "belongs to judge" do
      describe "#judge" do
        it "returns the rating's judge" do
          rating = Rating.first
          expected_judge = Person.find(rating.judge_id)

          expect(rating.judge).to eq expected_judge
        end

        it "returns a Person object" do
          rating = Rating.first
          expect(rating.judge).to be_instance_of Person
        end
      end

      describe "#judge=" do
        it "sets judge_id" do
          rating = Rating.new
          judge = Person.first

          expect{ rating.judge = judge }.to change{ rating.judge_id }.from(nil).to(judge.id)
        end
      end
    end
  end

  describe "validations" do
    before(:all) do
      Person.delete_all
      Person.create(first_name: "Teagan",  last_name: "Hickman")

      teagan = Person.find_by(first_name: "Teagan")

      Dog.delete_all

      Dog.create( { :name     => "Tenley",
                    :license  => "OH-9384764",
                    :age      => 1,
                    :breed    => "Golden Doodle",
                    :owner_id => teagan.id } )
    end

    before(:each) do

      Rating.delete_all

      Rating.create( { :coolness => 10,
                       :cuteness => 10,
                       :judge_id => 1,
                       :dog_id   => Dog.pluck(:id).first } )
    end

    let(:valid_details) do
      { :coolness => 7,
        :cuteness => 5,
        :judge_id => Person.pluck(:id).first,
        :dog_id   => Dog.pluck(:id).first }
    end

    it "requires coolness" do
      rating = Rating.new valid_details.except(:coolness)
      expect(rating).to be_invalid
    end

    it "requires cuteness" do
      rating = Rating.new valid_details.except(:cuteness)
      expect(rating).to be_invalid
    end

    describe "requiring a judge" do
      it "is invalid without a judge_id" do
        rating = Rating.new valid_details.except(:judge_id)
        expect(rating).to be_invalid
      end

      it "is invalid if judge_id doesn't point to an object" do
        nonexistant_judge_id = Person.pluck(:id).max + 1

        rating = Rating.new valid_details.merge(judge_id: nonexistant_judge_id)
        expect(rating).to be_invalid
      end
    end

    describe "requiring a dog" do
      it "is invalid without a dog_id" do
        rating = Rating.new valid_details.except(:dog_id)
        expect(rating).to be_invalid
      end

      it "is invalid if dog_id doesn't point to an object" do
        nonexistant_dog_id = Dog.pluck(:id).max + 1

        rating = Rating.new valid_details.merge(dog_id: nonexistant_dog_id)
        expect(rating).to be_invalid
      end
    end

    it "requires coolness to be at least 1" do
      rating = Rating.new valid_details.merge(coolness: 0)
      expect(rating).to be_invalid
    end

    it "requires coolness to be no more than 10" do
      rating = Rating.new valid_details.merge(coolness: 11)
      expect(rating).to be_invalid
    end

    it "requires cuteness to be at least 1" do
      rating = Rating.new valid_details.merge(cuteness: 0)
      expect(rating).to be_invalid
    end

    it "requires cuteness to be no more than 10" do
      rating = Rating.new valid_details.merge(cuteness: 11)
      expect(rating).to be_invalid
    end

    it "prohibits a judge from rating the same dog twice" do
      previous_rating = Rating.first
      previous_judge_dog_pair = { :judge_id => previous_rating[:judge_id],
                                  :dog_id   => previous_rating[:dog_id] }

      rating = Rating.new valid_details.merge(previous_judge_dog_pair)
      expect(rating).to be_invalid
    end
  end
end
