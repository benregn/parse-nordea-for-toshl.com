#!/usr/bin/env ruby
# encoding: utf-8
require 'CSV'
require 'json'
require 'date'
require "./helpers"

#=========================================#
# REMEMBER to save the CSV file as UTF-8! #
#=========================================#

# This should spit out: The name of the purchase place, the date after "Den"
# (optionally the time as well), and the amount
# After that maybe assign specific tags
module Nordea
  @filenames = ["nordea_sandra.csv"]

  def self.prepare_CSV
    rows = []
    columns_to_remove = ["Bogført", "Rentedato", "Saldo"]
    switch_keys = { "Tekst" => "Name", "Beløb" => "Amount" }

    @filenames.each do |filename|
      CSV.foreach(filename, col_sep: ';', headers: true) do |row|
        row = Helpers.change_key_name row, switch_keys

        if row["Name"].match("Den") && row["Name"].match("køb")
          columns_to_remove.each do |column|
            row.delete column
          end

          row = row.to_hash
          rows.push row
        else
          # No dates, no interest
        end
      end
    end
    return rows
  end

  def self.cleanup_data(row)
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

  def self.parse_date(row, rows)
    index = row["Name"].index("Den")
    date = row["Name"][index+3..-1].strip! # plus 3 to not include "Den"

    # remove the time from date
    if date.length > 5
      date = date[0..4]
    end

    row["Name"] = row["Name"][0..index-1].rstrip!
    date = Date.strptime(date, "%d.%m") # to be able to sort by date
    row.merge!("Date" => date)
  end

  def self.read_tags(filename)
    tag_file = File.read(filename)
    tags = JSON.parse(tag_file)
  end

  def self.match_tags(filename, row)
    tags = read_tags(filename)
    tags.each do |tag, value|
      value.each do |v| # each value is an array
        row["Name"].match(v) { row.merge!("Tag" => tag) }
      end
    end
  end

  def self.prepare_rows
    tags_filename = "tags.json"
    rows = prepare_CSV

    rows.each do |row|
      Nordea.cleanup_data row
      Nordea.parse_date row, rows
      Nordea.match_tags tags_filename, row
    end
    rows.sort_by! { |hash| hash["Date"] }
  end
end
