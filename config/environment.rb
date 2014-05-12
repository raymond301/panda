# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Panda::Application.initialize!

# Limit the number of lines able to upload from a single file to 1000.
Panda::Application.config.upload_limit = false

