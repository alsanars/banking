# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Agent do
  describe '#perform' do
    context 'intra-bank transfers (always successful)' do
      let(:bank) { Bank.new('INGDESMMXXX') }
      let(:origin) { Account.new(bank, 'Jim', 20_000) }
      let(:destination) { Account.new(bank, 'Emma', 2_000) }
      let(:transfers) do
        [
          Transfer::Intra.new(origin, destination, 1_500),
          Transfer::Intra.new(origin, destination, 3_000),
          Transfer::Intra.new(origin, destination, 15_500)
        ]
      end

      before do
        described_class.new(transfers).consume
      end

      it 'is successful' do
        expect(transfers.all?(&:success?)).to eq(true)
      end

      it 'subtract from origin balance' do
        expect(origin.balance).to eq(0)
      end

      it 'adds to destination balance' do
        expect(destination.balance).to eq(22_000)
      end

      it 'transfer added to transfers history' do
        expect(origin.bank.transfers.size).to eq(3)
      end
    end

    context 'inter-bank transfers (30% failure)' do
      let(:origin) { Account.new(Bank.new('INGDESMMXXX'), 'Jim', 20_000) }
      let(:destination) { Account.new(Bank.new('INGDUKLDX12'), 'Emma', 2_000) }
      let(:constraints) do
        { limit: 1000, commission: 5, failure: 30 }
      end
      let(:transfers) do
        Array.new(20) do
          Transfer::Inter.new(origin, destination, 1_000, constraints)
        end
      end

      before do
        described_class.new(transfers).consume
      end

      it 'is successful' do
        expect(transfers.all?(&:success?)).to eq(true)
      end

      it 'subtract from origin balance' do
        expect(origin.balance).to eq(-100)
      end

      it 'adds to destination balance' do
        expect(destination.balance).to eq(22_000)
      end

      it 'transfer added to transfers history' do
        expect(origin.bank.transfers.size).to eq(20)
      end
    end
  end
end
