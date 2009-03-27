module Mshiltonj;end;

## extends Rating from acts_as_rateable plugin
module Mshiltonj::Rating
  def self.included(klass)

    klass.class_eval {
      include Mshiltonj::Rating::InstanceMethods

      has_many :ratings, :as => :rateable, :dependent => :destroy

      unless self.const_defined? :RATINGS_CALLBACKS
        after_create  :update_ratings_rollup_after_create
        after_update  :update_ratings_rollup_after_update
        after_destroy :update_ratings_rollup_after_destroy
        self.const_set :RATINGS_CALLBACKS, true
      end

      if ! method_defined? :after_initialize
          def after_initialize; end;
      end
      
      alias_method_chain :after_initialize, :old_rating unless instance_methods.include? :after_initialize_without_old_rating
    }
  end


  module InstanceMethods
    def included(klass)
    end

    def after_initialize_with_old_rating(*args)
      #logger.warn "after init #{self.class}"
      @old_rating = self.rating ? self.rating : 0
      #after_initialize_without_old_rating(*args)
    end

    def update_ratings_rollup_after_create
      #puts "after create"
      return unless self.rateable.class.const_defined? :ROLLUP_RATINGS
      self.rateable.rollup.rating_count  += 1
      self.rateable.rollup.rating_total  += self.rating
     
      #puts self.rateable.rollup.inspect
      
      self.rateable.rollup.save
    end

    def update_ratings_rollup_after_update
      #puts "after update"
      return unless self.rateable.class.const_defined? :ROLLUP_RATINGS
      self.rateable.rollup.rating_total  -= @old_rating
      self.rateable.rollup.rating_total  += self.rating
      self.rateable.rollup.save
    end

    def update_ratings_rollup_after_destroy
      #puts "after destroy"
      return unless self.rateable.class.const_defined? :ROLLUP_RATINGS
      self.rateable.rollup.rating_count  -= 1
      self.rateable.rollup.rating_total  -= self.rating
      self.rateable.rollup.save
    end

  end

end
