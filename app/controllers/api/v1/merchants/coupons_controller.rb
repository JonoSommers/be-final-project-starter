class Api::V1::Merchants::CouponsController < ApplicationController
    
    def index
        options = {}
        merchant = Merchant.find(params[:merchant_id])
        if merchant.valid?
            options[:meta] = {count: (Merchant.get_all_merchants_coupons(merchant).count)}
            render json: CouponSerializer.new(Merchant.get_all_merchants_coupons(merchant), options), status: :ok
        else
            render_error
        end
    end
end