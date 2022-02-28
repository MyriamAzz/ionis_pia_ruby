module ExportVente
  extend self

  def csv_process_active(tab)
    directory_name = "public/export"
    public_directory_name = "export"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    filename = SecureRandom.hex(4) + "_EXPORT_VENTE_" + DateTime.now.strftime("%d_%m_%Y")
    file = "#{directory_name}/#{filename}.csv"

    subscriptions = UserFinancierSubscription.where(id: tab)

    headers = ["code journal", "date de piece", "no facture", "libelle", "compte general", "code tier",
         "libelle 2", "analytique/general", "Section analytic", "mode de reglement", "date d'échéance",
        "debit", "credit", "nom", "année", "?", "modalité", "statut"]
    
    CSV.open(file, 'w', write_headers: true, headers: headers, :col_sep => ";", :encoding => "ISO-8859-1") do |csv|
        subscriptions.each do |sub|
            csv << [sub.user_financier.id, sub.user_financier.nom, "CSV", "data"]
        end
    end

    Thread.new {
        sleep 10
        File.delete(file) if File.exist?(file)
    }
    return Rails.application.routes.default_url_options[:host] + "/" + public_directory_name + "/" + filename + ".csv"
  end

  def csv_done_active(tab)
    directory_name = "public/export"
    public_directory_name = "export"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    filename = SecureRandom.hex(4) + "_EXPORT_VENTE_" + DateTime.now.strftime("%d_%m_%Y")
    file = "#{directory_name}/#{filename}.csv"

    subscriptions = UserFinancierSubscription.where(id: tab)

    headers = ["code journal", "date de piece", "no facture", "libelle", "compte general", "code tier",
         "libelle 2", "analytique/general", "Section analytic", "mode de reglement", "date d'échéance",
        "debit", "credit", "nom", "année", "?", "modalité", "statut"]
    
    CSV.open(file, 'w', write_headers: true, headers: headers, :col_sep => ";", :encoding => "ISO-8859-1") do |csv|
        subscriptions.each do |sub|
            csv << [sub.user_financier.id, sub.user_financier.nom, "CSV", "data"]
        end
    end

    Thread.new {
        sleep 10
        File.delete(file) if File.exist?(file)
    }
    return Rails.application.routes.default_url_options[:host] + "/" + public_directory_name + "/" + filename + ".csv"
  end
end
