# ActsAsRateableRollup
require 'rating_ext'
require 'comment_ext'
require 'vote_ext'

require 'ugc_rollup'

module Mshiltonj; end;
module Mshiltonj::Acts; end;

module Mshiltonj::Acts::UgcRollup
  def self.included(klass)
    klass.extend(ClassMethods) 
  end

  module ClassMethods
    def acts_as_rateable_rollup
      require 'rating' # from acts_as_rateable, otherwise the class lookup fails
      acts_as_rateable

      has_one :ugc_rollup, :as => :ugc_rollupable, :dependent => :destroy

      include Mshiltonj::Acts::UgcRollup::RateableInstanceMethods
      extend  Mshiltonj::Acts::UgcRollup::RateableSingletonMethods

      unless instance_methods.include? :rollup
        include Mshiltonj::Acts::UgcRollup::InstanceMethods 
      end
     
      const_set :ROLLUP_RATINGS, true

      Rating.class_eval {
        include Mshiltonj::Rating
      }
    end

    def acts_as_commentable_rollup
      require 'comment' # from acts_as_rateable, otherwise the class lookup fails
      acts_as_commentable
      has_one :ugc_rollup, :as => :ugc_rollupable, :dependent => :destroy

      unless instance_methods.include? :rollup
        include Mshiltonj::Acts::UgcRollup::InstanceMethods 
      end
      #include Mshiltonj::Acts::::InstanceMethods
      extend Mshiltonj::Acts::UgcRollup::CommentableSingletonMethods
      
      const_set :ROLLUP_COMMENTS, true

      Comment.class_eval {
        include Mshiltonj::Comment
      }

    end
=begin
    def acts_as_voteable_rollup
      require 'vote' # from acts_as_voteable, otherwise the class lookup fails
      acts_as_voteable
      has_one :ugc_rollup, :as => :ugc_rollupable, :dependent => :destroy
      #include Mshiltonj::Acts::RateableRollup::InstanceMethods
      #extend Mshiltonj::Acts::RateableRollup::SingletonMethods

      const_set :ROLLUP_VOTES, true

      Vote.class_eval {
        extend Mshiltonj::Vote::InstanceMethods
        include Mshiltonj::Vote::SingletonMethods
      }

    end
=end
  end

  module InstanceMethods
    def rollup
      self.ugc_rollup = UgcRollup.new(:ugc_rollupable => self) unless self.ugc_rollup
      self.ugc_rollup
    end
  end

  module RateableInstanceMethods
    def rebuild_rateable_rollup
      #self.rollup = self.ugc_rollup || UgcRollup.new(:ugc_rollupable => rec)
      puts 1
      self.rollup.rating_count = self.ratings.size
      puts 2
      self.rollup.rating_total = self.ratings.inject(0) do |memo, r| memo + r.rating end
      puts 3
      self.rollup.save
    end
  end

  module RateableSingletonMethods
    def rebuild_rateable_rollups
      puts "... this could take a while ... "
      step = 100
      offset = 0 
      while records = self.find(:all, :limit => step, :offset => offset)
        break if records.blank?
        print "."
        STDOUT.flush
        records.each do |rec|
          rec.rebuild_rateable_rollup
        end
        offset += step
      end
    end
  end

  module CommentableSingletonMethods
    def rebuild_commentable_rollups
      puts "... this could take a while ... "
      step = 100
      offset = 0 
      while records = self.find(:all, :limit => step, :offset => offset)
        break if records.blank?
        print "."
        STDOUT.flush
        records.each do |rec|
          ugc_rollup = rec.ugc_rollup || UgcRollup.new(:ugc_rollupable => rec)
          ugc_rollup.comment_count = rec.comments.size
          ugc_rollup.save
        end
        offset += step
      end
    end
  end
=begin
  module VoteableSingletonMethods
    def rebuild_voteable_rollups
      puts "... this could take a while ... "
      step = 100
      offset = 0 
      while records = self.find(:all, :limit => step, :offset => offset)
        break if records.blank?
        print "."
        STDOUT.flush
        records.each do |rec|
          ugc_rollup = rec.ugc_rollup || UgcRollup.new(:ugc_rollupable => rec)
          ugc_rollup.rating_count = rec.ratings.size
          ugc_rollup.rating_total = rec.ratings.inject(0) do |memo, r| memo + r.rating end
          ugc_rollup.save
        end
        offset += step
      end
    end
  end
=end

end
