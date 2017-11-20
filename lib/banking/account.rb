# frozen_string_literal: true

require 'active_model'

class Account
  include ActiveModel::Validations

  attr_reader :owner, :number
  attr_accessor :bank, :balance

  validate  :bank_format
  validates :owner, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def initialize(bank, owner, balance = 0)
    @bank    = bank
    @owner   = owner
    @balance = balance
    @number  = Array.new(20) { rand(0..9) }.join
    validate!
  end

  # amount arg. positive to add, negative to subtract
  def update_balance!(amount)
    self.balance = (balance + amount).round(2)
  end

  private

  def validate!
    return if valid?
    raise ArgumentError, errors.full_messages.join(', ').to_s
  end

  def bank_format
    return if bank.is_a?(Bank)
    errors[:bank] << 'is not a Bank Object'
  end
end
