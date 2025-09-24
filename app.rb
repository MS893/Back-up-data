# appel des gems du Gemfile
require 'rubygems'
require 'pry'
require 'pp'
require 'json'
require 'bundler'
Bundler.require

# appel des librairies sans relative path
$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/emails'

# binding.pry

# Pour éviter que RSPEC exécute le code ci-dessus.
if __FILE__ == $0

  # JSON
  # Emails.new.save_as_JSON
  obj = Emails.new.read_JSON
  pp obj  # affiche le fichier json

  # GOOGLE SPREADSHEET
  # Emails.new.save_as_spreadsheet
  # Emails.new.read_spreadsheet

  # CSV
  # Emails.new.save_as_CSV
  read_CSV = Emails.new.read_CSV
  pp read_CSV

  # Emails.new.perform

end
