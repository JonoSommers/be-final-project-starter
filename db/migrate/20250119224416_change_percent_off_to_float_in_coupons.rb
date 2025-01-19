class ChangePercentOffToFloatInCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column :coupons, :percent_off, :float
  end
end
