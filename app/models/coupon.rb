class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :percent_off, numericality: {greater_than_or_equal_to: 0}, presence: true
    validates :dollar_off, numericality: {greater_than_or_equal_to: 0}, presence: true
    validates :merchant_id, presence: true
    validates :status, inclusion: { in: ["active", "inactive"] }, presence: true

    after_initialize :default_inactive

    def self.coupon_usage(coupon)
        Invoice.where(coupon_id: coupon.id).count
    end

    def self.active_status_change(coupon)
        coupon.update(status: "inactive")
    end

    def self.inactive_status_change(coupon)
        coupon.update(status: "active")
    end

    def default_inactive
        if new_record?
            self.status = "inactive"
        end
    end

    def self.has_met_coupon_limit(coupon)
        merchant = Merchant.find(coupon.merchant_id)
        merchant.coupons.where(status: 'active').count >= 5
    end

    def self.active_coupons
        Coupon.where(status: "active")
    end

    def self.inactive_coupons
        Coupon.where(status: "inactive")
    end
end