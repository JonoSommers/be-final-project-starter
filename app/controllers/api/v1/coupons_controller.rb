class Api::V1::CouponsController < ApplicationController

    def show
        options = {}
        coupon = Coupon.find(params[:id])
        options[:meta] = {usage_count: Coupon.coupon_usage(coupon)}
        render json: CouponSerializer.new(coupon, options), status: :ok
    end

    def create
        coupon = Coupon.new(coupon_params)
        if coupon.valid?
            coupon.save
            render json: CouponSerializer.new(coupon), status: :created
        else
            render json: { message: 'Validation Failed', errors: coupon.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
    end

    def update
        if params[:status] == "deactivate"
            coupon = Coupon.find(params[:id])
            Coupon.active_status_change(coupon)
            render json: CouponSerializer.new(coupon), status: :ok

        elsif params[:status] == "activate"
            coupon = Coupon.find(params[:id])
            Coupon.inactive_status_change(coupon)
            render json: CouponSerializer.new(coupon), status: :ok
        end
    end

    private

  def coupon_params
    params.permit(:name, :code, :percent_off, :dollar_off, :merchant_id, :status)
  end
end