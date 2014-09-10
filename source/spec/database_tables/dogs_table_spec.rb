require_relative '../spec_helper'


describe "dogs table" do

  let(:database_connection) { ActiveRecord::Base.connection }


  it "dogs table in the database" do
    dogs_table = database_connection.table_exists?(:dogs)

    expect(dogs_table).to be_truthy
  end


  it "has columns with the right names" do
    expected_column_names = ["id", "age", "name", "license", "owner_id", "created_at", "updated_at", "breed"].sort
    actual_column_names   = database_connection.columns(:dogs).map(&:name).sort

    expect(actual_column_names).to eq expected_column_names
  end


  it "has columns of the proper type" do
    expected_column_types_and_names = { :integer => ["id", "age", "owner_id"].sort,
                                        :string => ["name", "license", "breed"].sort,
                                        :datetime => ["created_at", "updated_at"].sort }

    dogs_table_columns = database_connection.columns(:dogs)

    actual_column_types_and_names = dogs_table_columns.each_with_object Hash.new(Array.new) do |column, memo|
                                      memo[column.type] += [column.name]
                                      memo[column.type].sort!
                                    end

    expect(actual_column_types_and_names).to eq expected_column_types_and_names
  end
end

