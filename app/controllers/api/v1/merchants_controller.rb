class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    if params[:sorted].present? && params[:sorted] == "age"
      merchants = merchants.sorted_by_creation
    elsif params[:status].present?
      merchants = Merchant.filter_by_status(params[:status])
    end
    
    include_count = params[:count].present? && params[:count] == "true"
    coupons_invoices_count = !params[:count].present? && !params[:sorted].present? && !params[:status].present?
    render json: MerchantSerializer.new(merchants, { params: { count: include_count, coupon_count: coupons_invoices_count, invoice_coupon_count: coupons_invoices_count}})
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create!(merchant_params) # safe to use create! here because our exception handler will gracefully handle exception
    render json: MerchantSerializer.new(merchant), status: :created
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update!(merchant_params)

    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy
  end

  private

  def merchant_params
    params.permit(:name)
  end
end
