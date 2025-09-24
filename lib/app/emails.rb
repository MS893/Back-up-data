class Emails

require 'nokogiri'
require 'open-uri'
require "google_drive"
require 'csv'
require 'json'


  # Méthode pour scraper les informations des mairies
  def townhall_scrapper

    url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'
    townhall_list = []
    mayor_links = []

    begin

      page = Nokogiri::HTML(URI.open(url))
      # je fais une boucle car je n'ai pas trouvé le xpath qui englobe les 20 mairies
      for i in (1..20)
        str = "///*[@id=\"result_#{i}\"]//a"
        mayor_links << page.xpath(str)   
      end

      mayor_links.each do |link|
        townhall_name = link.text.strip.split(" - ")[1]
        print "*" # sorte de barre de progression (traitement long)
        next if townhall_name.empty?
        # Récupère l'URL de la fiche de la mairie
        townhall_url = link[0]['href']
        email = get_townhall_email(townhall_url)
        townhall_list << {
          "townhall_name" => townhall_name,
          "email" => email
        }
      end

    rescue OpenURI::HTTPError => e
      puts "Erreur HTTP : #{e.message}"
      puts "Le site a peut-être bloqué l'accès. (Code d'erreur : #{e.io.status[0]})"
      townhall_list[0] = "err"
    end

    townhall_list

  end

  # Méthode pour récupérer l'email sur la page d'une mairie
  def get_townhall_email(url)
    begin
      page = Nokogiri::HTML(URI.open(url))
      email_link = page.at_css('a.send-mail[href^="mailto:"]')
      return email_link ? email_link.text.strip : "Email non trouvé"
    rescue OpenURI::HTTPError => e
      puts "Erreur lors de l'accès à la page de la mairie #{url}: #{e.message}"
      return "Pas d'email disponible"
    end
  end

  # affiche les emails à la console
  def perform
    result = townhall_scrapper()
    if (result.is_a?(Array) && result.first == "err") || result.empty?
      puts "Impossible d'afficher les mairies, le site internet est peut-être en maintenance"
    else
      puts "Liste des 20 premières villes du Val d'Oise :"
      result.each do |townhall|
        puts "- #{townhall['townhall_name']}: #{townhall['email']}"
      end
    end
  end

  # suvegarde les emails dans un fichier JSON
  def save_as_JSON
    result = townhall_scrapper()
    File.open('db/emails.json', 'w') do |f|
      f.write(result.to_json)
    end
    puts "Les données ont été sauvegardées avec succès dans db/emails.json"
  end

  # lecture du fichier JSON emails.json
  def read_JSON
    json = File.read('db/emails.json')
    obj = JSON.parse(json)
    return obj  # affiche le fichier json
  end

  # sauvegarde les emails dans Google Spreadsheet
  def save_as_spreadsheet
    # Creates a session. This will prompt the credential via command line for the
    # first time and save it to config.json file for later usages.
    # See this document to learn how to create config.json:
    # https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
    session = GoogleDrive::Session.from_config("db/config.json")
        # First worksheet of
    # https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
    # Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web
    ws = session.spreadsheet_by_key("pz7XtlQC-PYx-jrVMJErTcg").worksheets[0]
    # Changes are not sent to the server until you call ws.save().
    result = townhall_scrapper()
    i = 0
    result.each do |townhall|
      i += 1
      ws[i, 1] = townhall['townhall_name']
      ws[i, 2] = townhall['email']
    end
    ws.save
    # Reloads the worksheet to get changes by other clients.
    ws.reload
  end

  # lit les emails dans Google Spreadsheet
  def read_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("pz7XtlQC-PYx-jrVMJErTcg").worksheets[0]
    # Dumps cells.
    (1..ws.num_rows).each do |row|
      (1..ws.num_cols).each do |col|
        p ws[row, col]
      end
    end
  end

  # sauvegarde les emails dans un fichier CSV
  def save_as_CSV
    result = townhall_scrapper
    if result.nil? || result.empty? || (result.is_a?(Array) && result.first == "err")
      puts "Aucune donnée à sauvegarder dans le fichier CSV."
      return
    end
    CSV.open('db/emails.csv', 'w') do |csv|
      # Ajoute les en-têtes, y compris la colonne "N°"
      csv << ["Line number"] + result.first.keys
      # Ajoute les données pour chaque mairie avec un numéro de ligne
      result.each_with_index { |hash, index| csv << [index + 1] + hash.values }
    end
    puts "Les données ont été sauvegardées avec succès dans db/emails.csv"
  end

  # lit les emails depuis un fichier CSV et les affiche
  def read_CSV
    file_path = 'db/emails.csv'
    unless File.exist?(file_path)
      puts "Le fichier #{file_path} n'existe pas."
      return []
    end
    puts "Contenu du fichier CSV :"
    data = CSV.read(file_path)
    return data
    # code en utilisant CSV.foreach (permet de formater la sortie) :
    #data = []
    #CSV.foreach(file_path, headers: true) do |row|
    #  row_hash = row.to_h
    #  puts "- #{row_hash['townhall_name']}: #{row_hash['email']}"
    #  data << row_hash
    #end
    #data
  end

end