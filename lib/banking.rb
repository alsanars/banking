# frozen_string_literal: true

require 'pry'
require 'banking/bank'
require 'banking/account'
require 'banking/agent'
require 'banking/transfer/inter'
require 'banking/transfer/intra'

# Intra-Bank case:
puts "\nIntra-Bank case"

bank_a = Bank.new('INGDESMMXXX')
bank_b = Bank.new('INGDESMMXXX')

puts "- From #{bank_b.bic} To #{bank_a.bic}\n"

account_a = Account.new(bank_a, 'Emma', 0)
account_b = Account.new(bank_b, 'Jim', 20_000)

intra_transfer = Transfer::Intra.new(account_b, account_a, 20_000)

transfers = []
transfers << intra_transfer

consumer = Agent.new(transfers)
consumer.consume

account_b.bank.transfers.each do |transfer|
  Pry::ColorPrinter.pp(transfer, out = $>, width = 200)
end

# Inter-Bank case:
puts "\nInter-Bank case\n"

bank_a = Bank.new('INGDESMMXXX')
bank_b = Bank.new('INGDUKLLXXX')

puts "- From #{bank_b.bic} To #{bank_a.bic}\n"

account_a = Account.new(bank_a, 'Emma', 0)
account_b = Account.new(bank_b, 'Jim', 20_000)

constraints = { limit: 1000, commission: 5, failure: 30 }
transfer = Transfer::Inter.new(account_b, account_a, 1_000, constraints)

transfers = []
Array.new(20) { transfers << transfer }

consumer = Agent.new(transfers)
consumer.consume

account_b.bank.transfers.each do |transfer|
  Pry::ColorPrinter.pp(transfer, out = $>, width = 200)
end
