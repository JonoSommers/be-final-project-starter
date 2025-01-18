class Api::V1::Merchants::CouponsController < ApplicationController

    def index
        options = {}
        merchant = Merchant.find(params[:merchant_id])
        options[:meta] = {count: (Merchant.coupon_count(merchant).count)}
        render json: CouponSerializer.new(Merchant.coupon_count(merchant), options), status: :ok
    end
end