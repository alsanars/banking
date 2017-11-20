# frozen_string_literal: true

require 'active_model'

class Bank
  include ActiveModel::Validations

  attr_reader :bic, :transfers

  BIC = /\A[A-Z]{4}[A-Z]{2}[A-Z|0-9]{2}[A-Z|0-9]{3}\z/

  validates :bic, presence: true, format: { with: BIC }

  def initialize(bic)
    @bic       = bic
    @transfers = []
    validate!
  end

  def transfer_list(transfer)
    log = Struct.new(:date, :origin, :destination, :amount)
    transfer = log.new(Time.now.utc.to_s,
                       transfer.origin.number,
                       transfer.destination.number,
                       transfer.amount)
    transfers << transfer
  end

  private

  def validate!
    return if valid?
    raise ArgumentError, errors.full_messages.join(', ').to_s
  end
end
