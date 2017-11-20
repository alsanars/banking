# frozen_string_literal: true

class Agent
  attr_accessor :transfers

  def initialize(transfers = [])
    @transfers = transfers.inject(Queue.new, :push)
  end

  # Thread Pooling
  def consume
    workers = Array.new(transfers.size) do |worker|
      Thread.new(worker) do
        until transfers.empty?
          transfer = transfers.pop
          transfer.perform
          next if transfer.success?
          transfers.push(transfer)
        end
      end
    end
    workers.map(&:join)
  end
end
