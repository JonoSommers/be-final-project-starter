FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    customer
    merchant
    coupon
  end
end