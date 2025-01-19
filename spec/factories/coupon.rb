FactoryBot.define do
    factory :coupon do
        name { Faker::Commerce.product_name + " Discount" }
        code { Faker::Commerce.promotion_code }
        percent_off { 0 }
        dollar_off { Faker::Number.between(from: 5, to: 25).to_f.round(2) }
        merchant
        status {"inactive"}
    end
end