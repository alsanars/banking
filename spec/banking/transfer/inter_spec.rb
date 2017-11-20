# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transfer::Inter do
  let(:origin) do
    Account.new(Bank.new('INGDESMMXXX'), 'Jim', 10_000)
  end
  let(:destination) do
    Account.new(Bank.new('INGDUKLDX12'), 'Emma', 2_000)
  end

  describe '#initialize' do
    context 'without arguments' do
      subject(:inter) { described_class.new }

      it 'raises an error' do
        expect { inter }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#validate!' do
    context 'amount rebases limit' do
      let(:constraints) do
        { limit: 900, commission: 5, failure: 30 }
      end

      it 'raises an error' do
        expect { described_class.new(origin, destination, 1_000, constraints) }
          .to raise_error(ArgumentError, 'Amount is greather than limit allowed')
      end
    end

    context 'invalid  failure rate' do
      let(:constraints) do
        { limit: 1000, commission: 5, failure: 200 }
      end

      it 'raises an error' do
        expect { described_class.new(origin, destination, 1_000, constraints) }
          .to raise_error(ArgumentError, 'Failure is not included in the list')
      end
    end

    context 'invalid  commission' do
      let(:constraints) do
        { limit: 1000, commission: -5, failure: 30 }
      end

      it 'raises an error' do
        expect { described_class.new(origin, destination, 1_000, constraints) }
          .to raise_error(ArgumentError, 'Commission must be greater than or equal to 0')
      end
    end

    describe '#perform' do
      subject(:inter) do
        described_class.new(origin, destination, 1_000, constraints)
      end

      context 'it fails (failure 100%)' do
        let(:constraints) do
          { limit: 1_000, commission: 5, failure: 100 }
        end

        before do
          subject.perform
        end

        it 'keeps pending' do
          expect(inter.pending?).to eq(true)
        end

        it 'origin balance does not change' do
          expect(origin.balance).to eq(10_000)
        end

        it 'destination balance does not change' do
          expect(destination.balance).to eq(2_000)
        end

        it 'transfers history is empty' do
          expect(origin.bank.transfers.size).to eq(0)
        end
      end

      context 'success (failure 0%)' do
        let(:constraints) do
          { limit: 1_000, commission: 5, failure: 0 }
        end

        before do
          subject.perform
        end

        it 'is successful' do
          expect(inter.success?).to eq(true)
        end

        it 'subtract from origin balance applying commission' do
          expect(origin.balance).to eq(8_995)
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
end
