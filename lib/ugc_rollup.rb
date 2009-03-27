class UgcRollup < ActiveRecord::Base
  belongs_to :ugc_rollupable, :polymorphic => true

  before_save :set_rating_average

  def set_rating_average
    return unless self.ugc_rollupable.class.const_defined? :ROLLUP_RATINGS
    if rating_count && rating_count > 0
      self.rating_average = rating_total.to_f / rating_count.to_f
    else
      self.rating_average = 0
    end
  end

  def after_initialize
     self.rating_total    = 0 unless self.rating_total
     self.rating_count    = 0 unless self.rating_count
     self.rating_average  = 0 unless self.rating_average
     self.comment_count   = 0 unless self.comment_count
     self.vote_total      = 0 unless self.vote_total
     self.vote_up_count   = 0 unless self.vote_up_count
     self.vote_down_count = 0 unless self.vote_down_count
  end

 
end
