# frozen_string_literal: true

require_relative "./decorator"
require_relative "./decoration_registry"

module Decorators
  module LazyDecorator
    include Decorator

    def decorate_method(method_name, decorator)
      DecorationRegistry.init_trace

      @decorators ||= []
      @decorators << { method_name: method_name, decorator: decorator }
    end

    def late_decorate_methods
      pending_decorators = @decorators.uniq

      # This registry needs to be smarter to prevent infinite loops.
      # - Store the decorators in some kind of class, where the decorator has a source and definition
      # - Provide methods on the registry for adding these in an idempotent way
      # - When processing the decorators, get pending decorators from the registry and process
      # - Mark these as processed but keep refs so we don't re-register them
      pending_decorators.each do |pending_decorator|
        method_name = pending_decorator[:method_name]
        decorator = pending_decorator[:decorator]

        if instance_methods.include?(method_name)
          decorate_instance_method(method_name, decorator)
        elsif methods.include?(method_name)
          decorate_class_method(method_name, decorator)
        else
          raise ArgumentError, "#{method_name} is not a class or instance method"
        end
      end

      # Empty the pending decorators in case something else triggers this tracepoint.
      # The checks in __decorate_method prevent the creation of infinite loops, but we may need to recreate
      # an decorator if a method gets overwritten.
      @decorators = []
    end
  end
end
