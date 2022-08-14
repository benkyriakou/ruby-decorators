# frozen_string_literal: true

# A simple wrapper for the TracePoint we use to check for decorators being late attached.
# If the
module Decorators
  class DecorationRegistry
    def self.init_trace
      @init_trace ||= TracePoint.new(:end) do |tp|
        subject = tp.self

        if subject.singleton_class.ancestors.include?(LazyDecorator)
          subject.late_decorate_methods
        end
      end.enable
    end
  end
end
