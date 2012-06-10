#!/usr/bin/env ruby
# encoding: utf-8
require 'CSV'
require 'json'
require "formatador"

#=========================================#
# REMEMBER to save the CSV file as UTF-8! #
#=========================================#

# This should spit out: The name of the purchase place, the date after "Den"
# (optionally the time as well), and the amount
# After that maybe assign specific tags

def prepare_CSV
  rows = []
  columns_to_remove = ["Bogført", "Rentedato", "Saldo"]
  switch_keys = { "Tekst" => "Name", "Beløb" => "Amount" }

  CSV.foreach("./nordeaOLD.csv", col_sep: ';', headers: true) do |row|
    row = change_key_name row, switch_keys

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

def change_key_name(hash, switch_keys)
  switch_keys.each do |old_key, new_key|
    hash[new_key] = hash[old_key]
    hash.delete old_key
  end
  return hash
end

def cleanup_data(row)
  row["Name"] = row["Name"][13..-1] # remove "Electron køb,"

  if row["Name"].start_with?(" . ")
    row["Name"] = row["Name"][3..-1]
  end

  if row["Amount"].start_with?("-")
    row["Amount"] = row["Amount"][1..-1]
  end
end

def parse_date(row, rows)
  index = row["Name"].index("Den")
  date = row["Name"][index+3..-1].strip! # plus 3 to not include "Den"
  row["Name"] = row["Name"][0..index-1].rstrip!
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
# puts rows
Formatador.display_table rows
