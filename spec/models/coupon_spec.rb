require 'rails_helper'

describe Coupon, type: :model do
    describe 'validations' do
        it { should validate_presence_of(:name)}
        it { should validate_presence_of(:code)}
        it { should validate_presence_of(:percent_off)}
        it { should validate_presence_of(:dollar_off)}
        it { should validate_presence_of(:merchant_id)}
        it { should validate_presence_of(:status)}
    end

    describe 'relationships' do
        it { should have_many :invoices }
        it { should belong_to :merchant }
    end

    describe "class methods" do
        it 'should get get the count for how many coupons have been used' do
            coupon = create(:coupon, status: 'active')
            invoice1 = create(:invoice, coupon_id: coupon.id)
            invoice2 = create(:invoice, coupon_id: coupon.id)
            invoice3 = create(:invoice, coupon_id: coupon.id)

            meta_count = Invoice.where(coupon_id: coupon.id).count

            expect(meta_count).to eq(3)
        end

        it 'should update a coupons status from active to inactive' do
            coupon = create(:coupon, status: 'active')
            Coupon.active_status_change(coupon)

            expect(coupon.status).to eq("inactive")
        end

        it 'should update a coupons status from inactive to active' do
            coupon = create(:coupon, status: 'inactive')
            Coupon.inactive_status_change(coupon)

            expect(coupon.status).to eq("active")
        end

        it 'should set a coupons status to inactive upon creation' do
            coupon = create(:coupon)

            expect(coupon.status).to eq("inactive")
        end

        it 'should return true if a merchant has 5 or more coupons' do
            merchant = create(:merchant)
            coupon1 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon2 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon3 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon4 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon5 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon6 = create(:coupon, merchant_id: merchant.id, status: 'active')

            result = Coupon.has_met_coupon_limit(coupon6)

            expect(result).to be(true)
        end

        it 'should return false if a merchant has less than 5 coupons' do
            merchant = create(:merchant)
            coupon1 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon2 = create(:coupon, merchant_id: merchant.id, status: 'active')
            coupon3 = create(:coupon, merchant_id: merchant.id, status: 'active')

            result = Coupon.has_met_coupon_limit(coupon3)

            expect(result).to be(false)
        end

        it 'should return all coupons with an active status' do
            active_coupons = create_list(:coupon, 5, status: 'active')
            inactive_coupons = create_list(:coupon, 3)

            response = Coupon.active_coupons

            expect(response.count).to eq(5)
            expect(response).to eq(active_coupons)
        end

        it 'should return all coupons with an inactive status' do
            active_coupons = create_list(:coupon, 5, status: 'active')
            inactive_coupons = create_list(:coupon, 3)

            response = Coupon.inactive_coupons

            expect(response.count).to eq(3)
            expect(response).to eq(inactive_coupons)
        end
    end
end