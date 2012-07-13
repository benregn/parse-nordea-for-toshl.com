# encoding: utf-8
require "formatador"
require "./parseNordea"
require "./parseToshl"

def compare_rows(nordea, toshl)
  if nordea["Date"] === toshl["Date"]
    if same_amount?(nordea["Amount"], toshl["Amount"])
      nordea["Toshled"] = 'Y'
    else
      nordea["Toshled"] = 'N'
    end
  end
end

def same_amount?(n_amount, t_amount)
  difference = (n_amount.to_f - t_amount.to_f).abs
  # puts difference
  if difference < 2
    return true
  else
    return false
  end
end

nordea_rows = Nordea.prepare_rows
toshl_rows = Toshl.prepare_CSV

toshl_rows.each do |t_row|
  nordea_rows.each do |n_row|
    compare_rows n_row, t_row
  end
end

Formatador.display_table nordea_rows, ["Toshled", "Amount", "Tag", "Date", "Name"]
