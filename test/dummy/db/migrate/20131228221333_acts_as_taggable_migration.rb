class ActsAsTaggableMigration < ActiveRecord::Migration
  def change
    create_table :tags, :force => true do |t|
      t.belongs_to :user, polymorphic: true, :null => false, index: true
      t.string :name, :null => false
      t.string :excerpt
      t.integer :taggings_count
      t.index :name, unique: true

      t.timestamps
    end

    create_table :taggings, :force => true do |t|
      t.belongs_to :tag, counter_cache: true, :null => false, index: true
      t.belongs_to :tagger, polymorphic: true, index: true
      t.belongs_to :taggable, polymorphic: true, :null => false, index: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, :limit => 128, :null => false

      t.timestamps
    end
  end
end
