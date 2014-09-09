require_relative '../spec_helper'


describe "ratings table" do

  let(:database_connection) { ActiveRecord::Base.connection }


  it "ratings table in the database" do
    ratings_table = database_connection.table_exists?(:ratings)

    expect(ratings_table).to be_truthy
  end


  it "has columns with the right names" do
    expected_column_names = ["id", "coolness", "cuteness", "judge_id", "dog_id", "created_at", "updated_at"].sort
    actual_column_names   = database_connection.columns(:ratings).map(&:name).sort

    expect(actual_column_names).to eq expected_column_names
  end


  it "has columns of the proper type" do
    integer_column_names  = ["id", "coolness", "cuteness", "judge_id", "dog_id"].sort
    datetime_column_names = ["created_at", "updated_at"].sort

    expected_column_types_and_names = { :integer  => integer_column_names,
                                        :datetime => datetime_column_names }

    ratings_table_columns = database_connection.columns(:ratings)

    actual_column_types_and_names = ratings_table_columns.each_with_object Hash.new(Array.new) do |column, memo|
                                      memo[column.type] += [column.name]
                                      memo[column.type].sort!
                                    end

    expect(actual_column_types_and_names).to eq expected_column_types_and_names
  end
end

