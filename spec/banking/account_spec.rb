# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Account do
  let(:bank) { Bank.new('INGDESMMXXX') }

  describe '#initialize' do
    context 'invalid arguments' do
      it 'raises an error' do
        expect { described_class.new }
          .to raise_error(ArgumentError)
      end
    end

    context 'account number' do
      subject(:account) { described_class.new(bank, 'Jim') }

      it { expect(account.number).to be_a(String) }
      it { expect(account.number.size).to eq(20) }
    end
  end

  describe '#validate!' do
    context 'invalid bank' do
      it 'raises an error' do
        expect { described_class.new(nil, 'Jim') }
          .to raise_error(ArgumentError, 'Bank is not a Bank Object')
      end
    end

    context 'invalid owner' do
      it 'raises an error' do
        expect { described_class.new(bank, nil) }
          .to raise_error(ArgumentError, "Owner can't be blank")
      end
    end

    context 'invalid balance' do
      it 'raises an error' do
        expect { described_class.new(bank, 'Jim', -10_000) }
          .to raise_error(ArgumentError, 'Balance must be greater than or equal to 0')
      end
    end
  end

  describe '#update_balance' do
    let(:account) { described_class.new(bank, 'Emma', 156.86) }

    context 'adding to balance' do
      subject(:adding_balance) { account.update_balance!(100.14) }

      it 'increases balance' do
        expect(adding_balance).to eq(257)
      end
    end

    context 'subtract balance' do
      subject(:adding_balance) { account.update_balance!(100.14 * -1) }

      it 'decreases balance' do
        expect(adding_balance).to eq(56.72)
      end
    end
  end
end
