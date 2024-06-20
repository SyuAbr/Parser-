require 'csv'
class Parser
  def initialize(path)
    @data = CSV.read(path, headers: true)
  end

  def pars_countries(output_file)
    countries = @data.select { |data| data['definition'] == 'ОКСМ' && data['prefix'] == 'mem-int' }
    save_data(output_file, countries, %w[код название значение]) do |data|
      [data['label'].to_i, country_name(data['label']), data['name']]
    end
  end

  def pars_regions(output_file)
    regions = @data.select { |data| data['name'].start_with?('NaimOKATO') }
    code_regions = @data.select { |data| data['name'].start_with?('OKATO') && data['prefix'] == 'mem-int' }.map { |row| row['label'] }
    save_data(output_file, regions, %w[код название значение]) do |data|
      [code_regions.shift, data['name'],data['label']]
    end
  end

  def pars_documents(output_file)
    documents = @data.select { |data| data['extended link role'].include?('Kod_documentaList') && data['prefix'] == 'mem-int' }
    save_data(output_file, documents, %w[название значение]) do |data|
      [data['label'], data['name']]
    end
  end

  def parse
    pars_countries('references/countries.csv')
    pars_documents('references/documents.csv')
    pars_regions('references/regions.csv')
  end

  def country_name(code)
    country_names = {}
    CSV.foreach('list_countries.csv', headers: true) do |row|
      country_names[row['code'].to_i] = row['name'].tr('"', '')
    end
    country_names[code.to_i]
  end

  def save_data(file_path, data, headers)
    CSV.open(file_path, 'w', write_headers: true, headers: headers) do |csv|
      data.each_with_index do |row, i|
        csv << yield(row, i)
      end
    end
  end
end

parser = Parser.new('model.csv')
parser.parse


