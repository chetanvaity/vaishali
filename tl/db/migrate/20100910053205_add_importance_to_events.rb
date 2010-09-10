class AddImportanceToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :importance, :integer, :after => :end
  end

  def self.down
    remove_column :events, :importance
  end
end
