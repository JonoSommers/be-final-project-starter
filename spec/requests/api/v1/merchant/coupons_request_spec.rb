require "rails_helper"

describe 'Merchant Coupons endpoint', :type => :request do
    before(:each) do
        @merchants = create_list(:merchant, 5)
        
        @coupon_1 = create(:coupon, merchant_id: @merchants[0].id)
        @coupon_2 = create(:coupon, merchant_id: @merchants[0].id)
        @coupon_3 = create(:coupon, merchant_id: @merchants[1].id)
        @coupon_4 = create(:coupon, merchant_id: @merchants[3].id)
        @coupon_5 = create(:coupon, merchant_id: @merchants[4].id)
    end

    describe 'Get all coupons for a merchant' do
        it 'should return all coupons for a Merchant by the Merchants ID' do
            get api_v1_merchant_coupons_path(merchant_id: @merchants[0].id)
            json = JSON.parse(response.body, symbolize_names: true)

            coupons_data = json[:data]
            coupon_1_data = json[:data][0][:attributes]
            
            expect(response).to have_http_status(:ok)
            expect(coupons_data).to be_an(Array)
            expect(json[:meta][:count]).to eq(2)
            expect(coupon_1_data[:name]).to eq(@coupon_1.name)
            expect(coupon_1_data[:code]).to eq(@coupon_1.code)
            expect(coupon_1_data[:percent_off]).to eq(@coupon_1.percent_off)
            expect(coupon_1_data[:dollar_off]).to eq(@coupon_1.dollar_off)
            expect(coupon_1_data[:merchant_id]).to eq(@merchants[0].id)
            expect(coupon_1_data[:status]).to eq(@coupon_1.status)
        end

        it 'should throw an error if the ID is invalid' do
            get api_v1_merchant_coupons_path(merchant_id: 99999)
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Couldn't find Merchant with 'id'=99999"])
        end
    end
end