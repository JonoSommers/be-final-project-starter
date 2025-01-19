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
            render json: { message: 'Creation Failed', errors: coupon.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
    end

    def update
        coupon = Coupon.find(params[:id])
        if params[:status] == "deactivate"
            Coupon.active_status_change(coupon)
            render json: CouponSerializer.new(coupon), status: :ok
        elsif params[:status] == "activate"
            if Coupon.has_met_coupon_limit(coupon) == true
                render json: { message: 'This Merchant already has 5 active coupons. Please deactivate one of this Merchant coupons before continuing.' }
            else
                Coupon.inactive_status_change(coupon)
                render json: CouponSerializer.new(coupon), status: :ok
            end
        else
            render json: { message: 'That is not a valid param. Please enter activate, or deactivate depending on your needs.'}
        end
    end

    private

    def coupon_params
        params.permit(:name, :code, :percent_off, :dollar_off, :merchant_id, :status)
    end
end