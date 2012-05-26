#!/usr/bin/env ruby
# encoding: utf-8
require 'CSV'

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

      row["Name"] = row["Name"][13..-1]
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

puts prepare_CSV
# p fix_keys(prepare_CSV)