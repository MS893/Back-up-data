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

  loop do
    # Affiche le menu
    puts "\n" + "=" * 40
    puts " " * 8 + "MENU DE GESTION DES EMAILS"
    puts "=" * 40
    puts ""
    puts "Choisissez une option :"
    puts "  a. Écrire les emails au format JSON"
    puts "  b. Lire et afficher le fichier emails.json"
    puts "  c. Écrire les emails au format CSV"
    puts "  d. Lire et afficher le fichier emails.csv"
    puts "  q. Quitter"
    puts ""
    print "Votre choix > "

    choice = gets.chomp.downcase

    case choice
    when 'a'
      puts "\nLancement de la sauvegarde en JSON..."
      Emails.new.save_as_JSON
    when 'b'
      puts "\nLecture du fichier JSON..."
      obj = Emails.new.read_JSON
      pp obj
    when 'c'
      puts "\nLancement de la sauvegarde en CSV..."
      Emails.new.save_as_CSV
    when 'd'
      puts "\nLecture du fichier CSV..."
      read_CSV = Emails.new.read_CSV
      pp read_CSV
    when 'q'
      puts "\nAu revoir"
      break
    else
      puts "\nErreur : Choix non valide. Veuillez réessayer."
    end

    # Pause pour que l'utilisateur puisse voir le résultat avant de ré-afficher le menu
    unless choice == 'q'
      puts "\nAppuyez sur Entrée pour continuer..."
      gets
    end

  end

  # GOOGLE SPREADSHEET
  # Emails.new.save_as_spreadsheet
  # Emails.new.read_spreadsheet

end
