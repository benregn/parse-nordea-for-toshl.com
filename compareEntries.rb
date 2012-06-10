# encoding: utf-8
require "formatador"
require "./parseNordea"
require "./parseToshl"

nordea_rows = Nordea.prepare_rows
toshl_rows = Toshl.prepare_CSV
