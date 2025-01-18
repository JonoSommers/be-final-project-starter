class ChangeDollarOffToFloatInCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column :coupons, :dollar_off, :float
  end
end
