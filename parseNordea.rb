#!/usr/bin/env ruby
# encoding: utf-8
require 'CSV'
require 'json'
require 'date'
require "formatador"
require "./helpers"

#=========================================#
# REMEMBER to save the CSV file as UTF-8! #
#=========================================#

# This should spit out: The name of the purchase place, the date after "Den"
# (optionally the time as well), and the amount
# After that maybe assign specific tags

include Helpers

def prepare_CSV
  rows = []
  columns_to_remove = ["Bogført", "Rentedato", "Saldo"]
  switch_keys = { "Tekst" => "Name", "Beløb" => "Amount" }

  CSV.foreach("./nordea.csv", col_sep: ';', headers: true) do |row|
    row = Helpers.change_key_name row, switch_keys

    if row["Name"].match("Den")
      columns_to_remove.each do |column|
        row.delete column
      end

      row = row.to_hash
      rows.push row
    else
      # No dates, no interest
    end
  end
  return rows
end

def cleanup_data(row)
  row["Name"] = row["Name"][13..-1] # remove "Electron køb,"

  if row["Name"].start_with?(" . ")
    row["Name"] = row["Name"][3..-1]
  end

  row["Name"].squeeze!(" ") # remove excessive space within strings

  if row["Amount"].start_with?("-")
    row["Amount"] = row["Amount"][1..-1]
  end

  # convert to float to be able to round off
  row["Amount"] = row["Amount"].gsub(',', '.').to_f.round(1)
  # convert back to string to be able to use Formatador's coloring
  row["Amount"] = row["Amount"].to_s
end

def parse_date(row, rows)
  index = row["Name"].index("Den")
  date = row["Name"][index+3..-1].strip! # plus 3 to not include "Den"

  if date.length > 5
    date = date[0..4]
  end

  row["Name"] = row["Name"][0..index-1].rstrip!
  date = Date.strptime(date, "%d.%m")
  row.merge!("Date" => date)
end

def read_tags(filename)
  tag_file = File.read(filename)
  tags = JSON.parse(tag_file)
end

def match_tags(filename, row)
  tags = read_tags(filename)
  tags.each do |tag, value|
    value.each do |v|
      row["Name"].match(v) { row.merge!("Tag" => tag) }
    end
  end
end

filename = "tags.json"
rows = prepare_CSV
rows.each do |row|
  cleanup_data row
  parse_date row, rows
  match_tags filename, row
end
rows.sort_by! { |hash| hash["Date"] }
# p rows
Formatador.display_table rows, ["Amount", "Tag", "Date", "Name"]
