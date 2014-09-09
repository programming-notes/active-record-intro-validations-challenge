require_relative '../spec_helper'


describe "people table" do

  let(:database_connection) { ActiveRecord::Base.connection }


  it "people table in the database" do
    people_table = database_connection.table_exists?(:people)

    expect(people_table).to be_truthy
  end


  it "has columns with the right names" do
    expected_column_names = ["id", "first_name", "last_name", "created_at", "updated_at"].sort
    actual_column_names   = database_connection.columns(:people).map(&:name).sort

    expect(actual_column_names).to eq expected_column_names
  end


  it "has columns of the proper type" do
    integer_column_names  = ["id"].sort
    string_column_names   = ["first_name", "last_name"].sort
    datetime_column_names = ["created_at", "updated_at"].sort


    expected_column_types_and_names = { :integer  => integer_column_names,
                                        :string   => string_column_names,
                                        :datetime => datetime_column_names }

    people_table_columns = database_connection.columns(:people)

    actual_column_types_and_names = people_table_columns.each_with_object Hash.new(Array.new) do |column, memo|
                                      memo[column.type] += [column.name]
                                      memo[column.type].sort!
                                    end

    expect(actual_column_types_and_names).to eq expected_column_types_and_names
  end
end

