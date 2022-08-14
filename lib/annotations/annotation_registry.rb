# frozen_string_literal: true

# A simple wrapper for the TracePoint we use to check for annotations being late attached.
# If the
module Annotations
  class AnnotatationRegistry
    def self.init_trace
      @init_trace ||= TracePoint.new(:end) do |tp|
        subject = tp.self

        if subject.singleton_class.ancestors.include?(LazyAnnotation)
          subject.late_annotate_methods
        end
      end.enable
    end
  end
end
