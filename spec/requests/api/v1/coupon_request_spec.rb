require "rails_helper"

describe 'Coupon endpoints', :type => :request do
    before(:each) do 
        @merchants = create_list(:merchant, 5)
        
        @coupon_1 = create(:coupon, merchant_id: @merchants[0].id)
        @coupon_2 = create(:coupon, merchant_id: @merchants[0].id)
        @coupon_3 = create(:coupon, merchant_id: @merchants[1].id)
        @coupon_4 = create(:coupon, merchant_id: @merchants[3].id)
        @coupon_5 = create(:coupon, merchant_id: @merchants[4].id)

        @invoice_1 = create(:invoice, coupon_id: @coupon_1.id)
        @invoice_2 = create(:invoice, coupon_id: @coupon_1.id)
        @invoice_3 = create(:invoice, coupon_id: @coupon_1.id)
    end

    describe 'Index' do
        it 'should return all coupons with an active status if the query param[:active] = true' do
            create_list(:coupon, 5, status: 'active')
            create_list(:coupon, 3, status: 'inactive')

            get api_v1_coupons_path, params: { active: 'true' }
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data]).to all(include(:id, :type, :attributes))
            expect(json[:meta][:count]).to eq(5)
        end

        it 'should return an empty body if there are no active coupons' do
            create_list(:coupon, 3, status: 'inactive')

            get api_v1_coupons_path, params: { active: 'true' }
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data]).to eq([])
            expect(json[:meta][:count]).to eq(0)
        end

        it 'should return all coupons with an inactive status if the query param[:inactive] = true' do
            create_list(:coupon, 5, status: 'active')
            create_list(:coupon, 3, status: 'inactive')

            get api_v1_coupons_path, params: { inactive: 'true' }
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data]).to all(include(:id, :type, :attributes))
            expect(json[:meta][:count]).to eq(8)
        end
    end

    describe 'GET coupon by id' do
        it 'should return a single coupon by ID' do
            get api_v1_coupon_path(id: @coupon_1.id)
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data]).to include(:id, :type, :attributes)
            expect(json[:data][:id]).to eq(@coupon_1.id.to_s)
            expect(json[:data][:type]).to eq("coupon")
            expect(json[:data][:attributes]).to include(:name, :code, :percent_off, :dollar_off, :merchant_id)
            expect(json[:data][:attributes][:name]).to eq(@coupon_1.name)
            expect(json[:meta][:usage_count]).to eq(3)
        end
    end

    describe 'POST coupon' do
        it 'should successfully create a Coupon with an inactive status when all attributes are present' do
            name = Faker::Commerce.product_name + " Discount"
            code = Faker::Commerce.promotion_code
            percent_off = 0
            dollar_off = Faker::Number.between(from: 5, to: 25).to_f.round(2)
            merchant_id = @merchants[2].id
            status = "active"

            body = {
                name: name,
                code: code,
                percent_off: percent_off,
                dollar_off: dollar_off,
                merchant_id: merchant_id,
                status: status
            }

            post api_v1_coupons_path, params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:created)
            expect(json[:data][:attributes][:name]).to eq(name)
            expect(json[:data][:attributes][:code]).to eq(code)
            expect(json[:data][:attributes][:percent_off]).to eq(percent_off)
            expect(json[:data][:attributes][:dollar_off]).to eq(dollar_off)
            expect(json[:data][:attributes][:merchant_id]).to eq(merchant_id)
            expect(json[:data][:attributes][:status]).to eq("inactive")
            expect(json[:data][:type]).to eq("coupon")

            expect(Coupon.last.name).to eq(name)
        end

        it 'should not create a Coupon that is missing attributes' do
            name = Faker::Commerce.product_name + " Discount"
            code = Faker::Commerce.promotion_code
            percent_off = 0
            merchant_id = @merchants[2].id
            status = "active"

            body = {
                name: name,
                code: code,
                percent_off: percent_off,
                merchant_id: merchant_id,
                status: status
            }

            post api_v1_coupons_path, params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json[:errors]).to eq(["Validation failed: Dollar off is not a number, Dollar off can't be blank"])
        end

        it 'should not create a Coupon that is trying to use an exisitng code' do
            coupon = create(:coupon, code: "testcode1234")

            name = Faker::Commerce.product_name + " Discount"
            code = "testcode1234"
            percent_off = 0
            dollar_off = 10
            merchant_id = @merchants[2].id
            status = "active"

            body = {
                name: name,
                code: code,
                percent_off: percent_off,
                dollar_off: dollar_off,
                merchant_id: merchant_id,
                status: status
            }

            post api_v1_coupons_path, params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Code has already been taken"])
        end
    end

    describe 'PATCH coupon/:id' do
        it 'should update a coupon from inactive to active if search param update=active' do
            coupon = create(:coupon, status: "inactive")
            status_change = "active"
            body = {
                name: coupon.name,
                code: coupon.code,
                percent_off: coupon.percent_off,
                dollar_off: coupon.dollar_off,
                merchant_id: coupon.merchant_id,
                status: status_change
            }

            patch "/api/v1/coupons/#{coupon.id}?status=activate", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data][:attributes][:status]).to eq(status_change)
            expect(Coupon.find(coupon.id).status).to eq(status_change)
        end

        it 'should update a coupon from active to inactive if search param update=inactive' do
            coupon = create(:coupon, status: "active")
            status_change = "inactive"
            body = {
                name: coupon.name,
                code: coupon.code,
                percent_off: coupon.percent_off,
                dollar_off: coupon.dollar_off,
                merchant_id: coupon.merchant_id,
                status: status_change
            }

            patch "/api/v1/coupons/#{coupon.id}?status=deactivate", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:ok)
            expect(json[:data][:attributes][:status]).to eq(status_change)
            expect(Coupon.find(coupon.id).status).to eq(status_change)
        end

        it 'should not allow for a coupon to be switched to active if its Merchant already has 5 active coupons' do
            create_list(:coupon, 5, merchant_id: @merchants[0].id, status: 'active')
            coupon = create(:coupon, merchant_id: @merchants[0].id, status: 'inactive')
            body = { status: 'activate' }

            patch "/api/v1/coupons/#{coupon.id}?status=activate", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json[:message]).to eq("This Merchant already has 5 active coupons. Please deactivate one of this Merchant coupons before continuing.")
        end
    end
end