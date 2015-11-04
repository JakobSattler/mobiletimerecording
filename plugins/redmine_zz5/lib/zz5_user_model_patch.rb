require_dependency 'user'

module Zz5UserModelPatch

    def self.included(base) # :nodoc:

        base.send(:include, InstanceMethods)

        base.class_eval do
            has_one :zz5_user_preference, :dependent => :destroy
            has_many :zz5_employments, :dependent => :destroy, :order => "start"
        end
    end

    module InstanceMethods

        def logTest
            Rails.logger.info "called test in users begin"
            Rails.logger.info "keys=" + User.reflections.keys.to_s
            Rails.logger.info "called test in users end"
        end

        def zz5_user_pref
          self.zz5_user_preference ||= Zz5UserPreference.new(:user => self)
        end
    end

end

User.send(:include, Zz5UserModelPatch)
