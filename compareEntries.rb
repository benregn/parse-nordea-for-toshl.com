# encoding: utf-8
require "formatador"
require "./parseNordea"
require "./parseToshl"

def same_amount?(n_amount, t_amount)
  difference = (n_amount.to_f - t_amount.to_f).abs
  # puts difference
  if difference < 2
    return difference
  else
    return false
  end
end

def add_to_date_hash(date_hash, row, source)
  date = row["Date"]
  if !date_hash.has_key? date
    date_hash[date] = Hash[:nordea, [], :toshl, []]
  end
  if !date_hash[date][source].include? row
    date_hash[date][source] << row
  end
end

def compare_amount(date_hash)
  date_hash.each_value do |date|
    date[:nordea].sort_by! { |nordea| nordea["Amount"] }
    date[:toshl].sort_by! { |toshl| toshl["Amount"] }

    date[:nordea].each do |nordea|
      date[:toshl].each do |toshl|
        if same_amount? nordea["Amount"], toshl["Amount"]
          nordea["Toshled"] = 'Y - ' << same_amount?(nordea["Amount"], toshl["Amount"]).round(3).to_s
        else
          nordea["Toshled"] = 'N'
        end
      end
    end
  end
end

nordea_rows = Nordea.prepare_rows
toshl_rows = Toshl.prepare_CSV

date_hash = {}

nordea_rows.each do |n_row|
  add_to_date_hash date_hash, n_row, :nordea
  toshl_rows.each do |t_row|
    add_to_date_hash date_hash, t_row, :toshl
    compare_amount date_hash
    # compare_rows n_row, t_row
  end
end

# p "nordea", date_hash[Date.new(2012, 06, 01)][:nordea]
# p "toshl", date_hash[Date.new(2012, 06, 01)][:toshl]
# p "2012-06-01", date_hash[Date.new(2012, 06, 01)]
p "date_hash", date_hash
# Formatador.display_table nordea_rows, ["Toshled", "Amount", "Tag", "Date", "Name"]
