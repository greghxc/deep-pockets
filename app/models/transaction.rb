class Transaction < ActiveRecord::Base
  has_many :activities, as: :subject

  attr_accessor :nonce_from_the_client

  after_create :schedule_transaction

  enum status: [:unprocessed, :scheduled, :in_progress, :paid, :cancelled, :failed]

  def cancel
    fail 'cannot cancel this transaction' unless unprocessed? || scheduled?
    fail 'cannot cancel this transaction' if complete
    self.status = 'cancelled'
    self.complete = true
    log_activity('cancelled')
    save
  end

  def process_payment
    fail 'cannot reprocess a complete transaction' if complete?
    fail 'transaction must be scheduled to process' unless scheduled?
    self.status = :in_progress
    save
    process_bt
    self.status = :paid
    log_activity('paid')
  rescue => e
    self.status = :failed
    log_activity('failed', e)
  ensure
    self.complete = true
    save
  end

  private

  def schedule_transaction
    fail 'cannot schedule a complete transaction' if complete?
    fail 'transaction must be unprocessed to process' unless unprocessed?
    result = create_bt_customer
    self.bt_customer = result.id
    self.bt_payment_method = result.payment_methods.first.token
    self.status = 'scheduled'
    log_activity('scheduled')
  rescue => e
    self.complete = true
    self.status = 'failed'
    log_activity('failed', e)
  ensure
    save
  end

  def create_bt_customer
    result = Braintree::Customer.create(
      last_name: res_num,
      company: client_name,
      payment_method_nonce: nonce_from_the_client
    )
    fail result.errors unless result.success?
    result.customer
  end

  def process_bt
    result = Braintree::Transaction.sale(
        amount: amount,
        order_id: res_num,
        customer_id: bt_customer,
        payment_method_token: bt_payment_method,
        :options => {
          :submit_for_settlement => false
        }
    )
    fail result.errors unless result.success?
    result
  end

  def log_activity(action, params = '')
    context = caller[0]
    Activity.create(
        subject: self,
        context: context,
        action: action,
        detail: params
    )
  end
end
