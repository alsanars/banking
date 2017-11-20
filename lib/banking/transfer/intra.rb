# frozen_string_literal: true

require 'active_model'
require 'observer'

module Transfer
  class Intra
    include ActiveModel::Validations
    include Observable

    STATES = %i[pending success].freeze

    attr_reader :origin, :destination, :amount
    attr_accessor :state

    validate  :accounts
    validates :amount, numericality: { greater_than_or_equal_to: 0 }

    def initialize(origin, destination, amount)
      @origin      = origin
      @destination = destination
      @amount      = amount
      pending!
      validate!
      add_observer(origin.bank, :transfer_list)
    end

    def perform
      return if random_failure?
      subtract!
      addition!
      success!
      changed
      notify_observers(self)
    end

    STATES.each do |state|
      define_method :"#{state}!" do
        self.state = state
      end

      define_method :"#{state}?" do
        self.state == state
      end
    end

    def random_failure?
      false
    end

    private

    def subtract!
      origin.update_balance!(amount * -1)
    end

    def addition!
      destination.update_balance!(amount)
    end

    def validate!
      return if valid?
      raise ArgumentError, errors.full_messages.join(', ').to_s
    end

    def accounts
      errors[:origin] << 'is not a Account Object' unless origin.is_a?(Account)
      errors[:destination] << 'is not a Account Object' unless destination.is_a?(Account)
    end
  end
end
