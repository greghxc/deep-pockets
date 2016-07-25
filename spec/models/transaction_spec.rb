require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:example) do
    @fake_customer = double
    @fake_payment_method = double
    allow(@fake_payment_method).to receive(:token).and_return('token_string')
    allow(@fake_customer).to receive(:success?).and_return(true)
    allow(@fake_customer).to receive(:id).and_return('123ABC')
    allow(@fake_customer).to receive(:payment_methods).and_return([@fake_payment_method])
    allow(@fake_customer).to receive(:customer).and_return(@fake_customer)
    allow(Braintree::Customer).to receive(:create).and_return(@fake_customer)
  end

  it { is_expected.to be_unprocessed }

  context 'after save' do
    before(:example) do
      subject.save
    end

    it { is_expected.to be_scheduled }

    it 'has correct bt info' do
      expect(subject.bt_customer).to eq('123ABC')
      expect(subject.bt_payment_method).to eq('token_string')
    end

    context 'when bt create fails' do
      before(:example) do
        failed_customer = double
        allow(failed_customer).to receive(:success?).and_return(false)
        allow(failed_customer).to receive(:errors).and_return('some errors')
        allow(failed_customer).to receive(:id).and_return('456ABC')
        allow(failed_customer).to receive(:customer).and_return(failed_customer)
        allow(Braintree::Customer).to receive(:create).and_return(failed_customer)
      end

      it 'marked completed' do
        transaction = Transaction.create
        expect(transaction).to be_complete
      end
      it 'is failed' do
        transaction = Transaction.create
        expect(transaction).to be_failed
      end
    end
  end

  describe '.cancel' do
    subject { Transaction.create }
    before(:each) { subject.cancel }

    it { is_expected.to be_cancelled }
    it { is_expected.to be_complete }
  end

  describe '.process_payment' do
    subject { Transaction.create }
    before(:each) do
      fake_transaction = double
      allow(fake_transaction).to receive(:success?).and_return(true)
      allow(Braintree::Transaction).to receive(:sale).and_return(fake_transaction)
      subject.process_payment
    end

    it { is_expected.to be_paid }
    it { is_expected.to be_complete }
  end
end
