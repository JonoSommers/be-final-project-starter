class Api::V1::CouponsController < ApplicationController

    def index
        options = {}
        if params[:active] == 'true'
            options[:meta] = {count: Coupon.active_coupons.count}
            render json: CouponSerializer.new(Coupon.active_coupons, options), status: :ok
        elsif params[:inactive] == 'true'
            options[:meta] = {count: Coupon.inactive_coupons.count}
            render json: CouponSerializer.new(Coupon.inactive_coupons, options), status: :ok
        else
            render_error
        end
    end

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
            creation_error(coupon)
        end
    end

    def update
        coupon = Coupon.find(params[:id])
        if params[:status] == "deactivate"
            Coupon.active_status_change(coupon)
            render json: CouponSerializer.new(coupon), status: :ok
        elsif params[:status] == "activate"
            if Coupon.has_met_coupon_limit(coupon)
                render json: { message: 'This Merchant already has 5 active coupons. Please deactivate one of this Merchant coupons before continuing.' }, status: :unprocessable_entity
            else
                Coupon.inactive_status_change(coupon)
                render json: CouponSerializer.new(coupon), status: :ok
            end
        else
            render_error
        end
    end

    private

    def coupon_params
        params.permit(:name, :code, :percent_off, :dollar_off, :merchant_id, :status)
    end
end