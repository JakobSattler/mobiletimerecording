class AddCalculationRateColumn < ActiveRecord::Migration
  def up
    add_column :zz5_employments, :calculation_rate, :float, :default => 1.0
  end
end