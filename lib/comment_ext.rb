module Mshiltonj;end;

## extends Comment from acts_as_commentable plugin
module Mshiltonj::Comment
  def self.included(klass)

    klass.class_eval {
      extend Mshiltonj::Comment::ClassMethods
      include Mshiltonj::Comment::InstanceMethods

      unless self.const_defined? :COMMENT_CALLBACKS
        after_create  :update_comments_rollup_after_create
        after_destroy :update_comments_rollup_after_destroy
        self.const_set :COMMENT_CALLBACKS, true
      end

    }
  end

  module InstanceMethods
    def included(klass)

    end

    def update_comments_rollup_after_create
      return unless self.commentable.class.const_defined? :ROLLUP_COMMENTS
      self.commentable.rollup.comment_count  += 1
      self.commentable.rollup.save
    end

    def update_comments_rollup_after_destroy
      return unless self.commentable.class.const_defined? :ROLLUP_COMMENTS
      self.commentable.rollup.comment_count  -= 1
      self.commentable.rollup.save
    end

  end

  module ClassMethods

  end


end
