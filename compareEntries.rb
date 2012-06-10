# encoding: utf-8
require "formatador"
require "./parseNordea"
require "./parseToshl"

tags_filename = "tags.json"
nordea_rows = Nordea.prepare_CSV
nordea_rows.each do |row|
  Nordea.cleanup_data row
  Nordea.parse_date row, nordea_rows
  Nordea.match_tags tags_filename, row
end
nordea_rows.sort_by! { |hash| hash["Date"] }
# p nordea_rows
Formatador.display_table nordea_rows, ["Amount", "Tag", "Date", "Name"]

toshl_rows = Toshl.prepare_CSV
