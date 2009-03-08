class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end

    Person.create(:name => 'Joakim', :age => 15)
    Person.create(:name => 'Jesper', :age => 16)
    Person.create(:name => 'Kristoffer', :age => 17)
  end

  def self.down
    drop_table :people
  end
end
