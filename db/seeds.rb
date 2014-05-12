# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

User.create!(
    :username => "0xCAFED00D",
    :password => "raymond",
    :password_confirmation => "raymond",
    :admin => true
)
#user.save!


config   = Rails.configuration
database = config.database_configuration[Rails.env]["database"]
user     = config.database_configuration[Rails.env]["username"]

puts "Loading Gene Table into MySQL ..."
system("mysql -u #{user} -p #{database} < #{Rails.root}/db/genes.dump")
puts "Loading Synonyms Table into MySQL ..."
system("mysql -u #{user} -p #{database} < #{Rails.root}/db/gene_synonyms.dump")
### mysqldump -u xxxxx panda_dev genes > ~/panda/db/genes.dump



