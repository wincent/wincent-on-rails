class Tagging < ActiveRecord::Base
  belongs_to  :tag, :counter_cache => true
  belongs_to  :taggable, :polymorphic => true

  def self.grouped_taggings_for_tag tag
    taggings = {}
    # not really "grouped" in the SQL sense (GROUP BY); rather, ordered
    find_all_by_tag_id(tag.id, :order => 'taggable_type').each do |t|
      if taggings[t.taggable_type].nil?
        taggings[t.taggable_type] = [t]
      else
        taggings[t.taggable_type] << t
      end
    end
    taggings
  end

end
