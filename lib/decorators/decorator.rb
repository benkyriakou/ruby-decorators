# frozen_string_literal: true

module Decorators
  module Decorator
    def decorate_method(method_name, decorator)
      if instance_methods.include?(method_name)
        decorate_instance_method(method_name, decorator)
      elsif methods.include?(method_name)
        decorate_class_method(method_name, decorator)
      else
        raise ArgumentError, "#{method_name} is not a class or instance method"
      end
    end

    # Here we just directly evaluate this in the context of the current class instance.
    def decorate_instance_method(method_name, decorator)
      __decorate_method(self, method_name, decorator)
    end

    # Here we must use the singleton as the context as singleton methods are instance methods on the singleton class.
    # We could also do this by wrapping the call in class << self but that is a bit gross.
    def decorate_class_method(method_name, decorator)
      __decorate_method(singleton_class, method_name, decorator)
    end

    private

    def __decorate_method(context, method_name, decorator)
      unless context.instance_methods.include?(decorator)
        raise ArgumentError, "#{decorator} is not a valid decorator"
      end

      # Prevent re-decorating a method to stop infinite loops.
      # @todo Make this smarter to allow multiple different decorators.
      if context.instance_method(method_name).original_name != method_name
        return
      end

      context.alias_method :"__decorated_#{method_name}", method_name

      context.define_method method_name do
        send(decorator) { send(:"__decorated_#{method_name}") }
      end
    end
  end
end
