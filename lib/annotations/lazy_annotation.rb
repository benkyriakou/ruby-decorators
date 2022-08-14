# frozen_string_literal: true

require_relative "./annotation"
require_relative "./annotation_registry"

module Annotations
  module LazyAnnotation
    include Annotation

    def annotate_method(method_name, annotation)
      AnnotatationRegistry.init_trace

      @annotations ||= []
      @annotations << { method_name: method_name, annotation: annotation }
    end

    def late_annotate_methods
      pending_annotations = @annotations.uniq

      # This registry needs to be smarter to prevent infinite loops.
      # - Store the annotations in some kind of class, where the annotation has a source and definition
      # - Provide methods on the registry for adding these in an idempotent way
      # - When processing the annotations, get pending annotations from the registry and process
      # - Mark these as processed but keep refs so we don't re-register them
      pending_annotations.each do |pending_annotation|
        method_name = pending_annotation[:method_name]
        annotation = pending_annotation[:annotation]

        if instance_methods.include?(method_name)
          annotate_instance_method(method_name, annotation)
        elsif methods.include?(method_name)
          annotate_class_method(method_name, annotation)
        else
          raise ArgumentError, "#{method_name} is not a class or instance method"
        end
      end

      # Empty the pending annotations in case something else triggers this tracepoint.
      # The checks in __annotate_method prevent the creation of infinite loops, but we may need to recreate
      # an annotation if a method gets overwritten.
      @annotations = []
    end
  end
end
