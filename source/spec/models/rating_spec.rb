require_relative '../spec_helper'

describe "Rating" do
  describe "inheritance" do
    it "inherits from ActiveRecord::Base" do
      expect(Rating < ActiveRecord::Base).to be true
    end
  end

  describe "validations" do
    before(:each) do
      Rating.delete_all

      Rating.create( { :coolness => 10,
                       :cuteness => 10,
                       :judge_id => 1,
                       :dog_id   => 1 } )
    end

    let(:valid_details) do
      { :coolness => 7,
        :cuteness => 5,
        :judge_id => 2,
        :dog_id   => 3 }
    end

    it "requires coolness" do
      rating = Rating.new valid_details.except(:coolness)
      expect(rating).to be_invalid
    end

    it "requires cuteness" do
      rating = Rating.new valid_details.except(:cuteness)
      expect(rating).to be_invalid
    end

    it "requires judge_id" do
      rating = Rating.new valid_details.except(:judge_id)
      expect(rating).to be_invalid
    end

    it "requires dog_id" do
      rating = Rating.new valid_details.except(:dog_id)
      expect(rating).to be_invalid
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
