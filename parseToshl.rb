# encoding: utf-8
require 'CSV'
require "./helpers"

module Toshl
  def self.prepare_CSV
    rows = []
    columns_to_remove = ["Income amount", "Currency", "Description"]
    switch_keys = { "Entry (tags)" => "Tag", "Expense amount" => "Amount" }

    CSV.foreach("./toshl_export.csv", col_sep: ',', headers: true) do |row|
      row = Helpers.change_key_name row, switch_keys
      columns_to_remove.each { |column| row.delete column }

      row = row.to_hash
      if not row["Amount"].empty?
        # puts row
        rows.push row
      end
    end
    return rows
  end
end
