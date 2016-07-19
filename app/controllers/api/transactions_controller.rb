class Api::TransactionsController < Api::ApiController
  def index
    search_term = params[:search] || ''
    @transactions = Transaction.where('res_num LIKE (?)', "%#{search_term}%").limit(100)
    render json: @transactions
  end

  def create
    ActionController::Parameters.permit_all_parameters = true
    @transaction = Transaction.create(params[:transaction])
    render json: @transaction
  end

  def show
    @transaction = Transaction.find(params[:id])
    render json: @transaction
  end

  def activities
    @transaction = Transaction.find(params[:id])
    render json: @transaction.activities
  end

  def edit
    ActionController::Parameters.permit_all_parameters = true
    @transaction = Transaction.find(params[:id])
    @transaction.cancel if params[:method] == 'cancel'
    @transaction.process_payment if params[:method] == 'process_payment'
    render json: @transaction
  end

end