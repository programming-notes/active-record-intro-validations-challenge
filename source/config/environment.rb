# Requre gems and Ruby libraries
require "active_record"
require "rspec"
require "rake"
require "sqlite3"
require "pathname"


# Identify the root directory for the application
# so that we can later reference files from APP_ROOT
path_to_root_directory = File.expand_path('../../', __FILE__)
APP_ROOT = Pathname.new(path_to_root_directory)


# Load the files in APP_ROOT/lib
lib_files = Dir[APP_ROOT.join('lib', '*.rb')]

lib_files.each do |file|
  require file
end


# Load the files in APP_ROOT/app/models/
model_files = Dir[APP_ROOT.join('app', 'models', '*.rb')]

model_files.each do |model_file|
  filename = File.basename(model_file, ".*")
  autoload ActiveSupport::Inflector.camelize(filename), model_file
end


# Set up ActiveRecord::Base to log its activity
ActiveRecord::Base.logger = Logger.new(STDOUT)


# Configure the database
database_config = { :adapter  =>  "sqlite3",
                    :database => "#{APP_ROOT}/db/dogs.sqlite3" }

ActiveRecord::Base.establish_connection(database_config)


# Establish connection between models and tables
ActiveRecord::Base.connection
