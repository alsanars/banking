# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transfer::Intra do
  let(:bank) { Bank.new('INGDESMMXXX') }
  let(:origin) { Account.new(bank, 'Emma', 10_000) }
  let(:destination) { Account.new(bank, 'Emma', 2_000) }

  describe '#initialize' do
    context 'invalid arguments' do
      it 'raises an error' do
        expect { described_class.new }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#validate!' do
    context 'invalid account' do
      it 'raises an error' do
        expect { described_class.new(nil, destination, 10_000) }
          .to raise_error(ArgumentError, 'Origin is not a Account Object')
      end
    end

    context 'invalid amount' do
      it 'raises an error' do
        expect { described_class.new(origin, destination, -10_000) }
          .to raise_error(ArgumentError, 'Amount must be greater than or equal to 0')
      end
    end
  end

  describe '#perform' do
    subject(:inter) do
      described_class.new(origin, destination, 1_000)
    end

    context 'success' do
      before do
        subject.perform
      end

      it 'is successful' do
        expect(inter.success?).to eq(true)
      end

      it 'subtract from origin balance' do
        expect(origin.balance).to eq(9_000)
      end

      it 'adds to destination balance' do
        expect(destination.balance).to eq(3_000)
      end

      it 'transfer added to transfers history' do
        expect(origin.bank.transfers.size).to eq(1)
      end
    end
  end
end
