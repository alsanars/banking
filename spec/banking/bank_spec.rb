# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bank do
  describe '#initialize' do
    context 'without arguments' do
      subject(:bank) { described_class.new }

      it 'raises an error' do
        expect { bank }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#validate!' do
    context 'invalid bic' do
      subject(:bank) { described_class.new(bic: 'foobar') }

      it 'initialize with bic and empty list of transfers' do
        expect { bank }.to raise_error(ArgumentError, 'Bic is invalid')
      end
    end
  end

  describe '#transfer_list' do
    let(:origin) { Account.new(bank, 'Jim', 1_000) }
    let(:destination) { Account.new(bank, 'Emma') }
    subject(:transfer) { Transfer::Intra.new(origin, destination, 1_000) }

    subject(:bank) { described_class.new('INGDESMMXXX') }

    before do
      bank.transfer_list(transfer)
    end

    it 'stores transfer as struct with date, origin, destination & amount' do
      expect(bank.transfers).to be_a(Array)
      expect(bank.transfers.first)
        .to have_attributes(date: kind_of(String),
                            origin: transfer.origin.number,
                            destination: transfer.destination.number,
                            amount: transfer.amount)
    end
  end
end
