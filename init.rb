# Include hook code here
require 'ez_ugc_rollup'
ActiveRecord::Base.send(:include, Mshiltonj::Acts::UgcRollup)
