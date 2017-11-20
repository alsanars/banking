# frozen_string_literal: true

require_relative 'intra'

module Transfer
  class Inter < Intra
    attr_reader :limit, :commission, :failure

    validates :commission, numericality: { greater_than_or_equal_to: 0 }
    validates :failure, inclusion: { in: 0..100 }
    validate  :amount_within_limit

    def initialize(origin, destination, amount, **constraints)
      @limit      = constraints.dig(:limit)
      @commission = constraints.dig(:commission)
      @failure    = constraints.dig(:failure)
      super(origin, destination, amount)
    end

    def random_failure?
      threshold = failure / Float(100)
      rand(0) < threshold
    end

    private

    def subtract!
      origin.update_balance!((commission + amount) * -1)
    end

    def amount_within_limit
      errors[:amount] << 'is greather than limit allowed' unless limit >= amount
    end
  end
end
