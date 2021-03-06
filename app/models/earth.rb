class Earth < ActiveRecord::Base
has_many :cearths

  def self.to_csv(options = {})
    (CSV.generate(options) do |csv|
      # column headers for table - language
      column_header = [ "Kод oбеспечення", "Тип обеспечения", "Область", "Район", "Город", "Тип улицы", "Название улицы", "Название улицы", "Номер дома", "Номер корпуса", "Номер квартиры", "Общая площадь, кв.м", "Жилая площадь, кв.м", "Площадь земельного участка, Га", "№ района", "Категория ремонту", "Рыночная стоимость, грн", "Рыночная стоимость, дол.США", "Рыночная стоимость, евро"]
      csv << column_names
      # column headers for table - language
      csv << column_header
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end).encode('Windows-1251')
  end

  def self.import(file)
    @array_error = Array.new([])
    allowed_attributes = [ "code_provision","tip","region","district","city","street_type",
                           "street_name","street_name2","number_home","number_housing",
                           "room_apartment","total_area","floor_area","area_land",
                           "district_number","category_repair","uah_market_value",
                           "usd_market_value","euro_market_value"]
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    header = [ "code_provision","tip","region","district","city","street_type",
               "street_name","street_name2","number_home","number_housing",
               "room_apartment","total_area","floor_area","area_land",
               "district_number","category_repair","uah_market_value",
               "usd_market_value","euro_market_value"]
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = find_by_id(row["code_provision"]) || new
      product.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
      #product.save!
      if product.valid?
        product.save!
      else
        @array_error.push(row["code_provision"])
      end
    end
  end


  def self.check_import_errors
    if @array_error.blank?
      true
    else
      false
      @array_error
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
      when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
