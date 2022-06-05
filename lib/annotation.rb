# frozen_string_literal: true

# require "pry-byebug"
#
# trace = TracePoint.new(:end) do |tp|
#   p tp.callee_id
#   p [tp.lineno, tp.defined_class, tp.method_id, tp.event, tp.self]
# end

# We could instead abuse this and attach tracepoints to our code which then get lazily evaluated when a class that
# extends Annotation invokes a method. We can then check if the class annotates that method and wrap the call (does
# tracepoint allow us to do that or is it too late?)
#
# trace.enable

module Annotation
  def annotate_method(method_name, annotation)
    if instance_methods.include?(method_name)
      annotate_instance_method(method_name, annotation)
    elsif methods.include?(method_name)
      annotate_class_method(method_name, annotation)
    else
      raise ArgumentError, "#{method_name} is not a class or instance method"
    end
  end

  # Here we just directly evaluate this in the context of the current class instance.
  def annotate_instance_method(method_name, annotation)
    __annotate_method(self, method_name, annotation)
  end

  # Here we must use the singleton as the context as singleton methods are instance methods on the singleton class.
  # We could also do this by wrapping the call in class << self but that is a bit gross.
  def annotate_class_method(method_name, annotation)
    __annotate_method(singleton_class, method_name, annotation)
  end

  private

  def __annotate_method(context, method_name, annotation)
    unless context.instance_methods.include?(annotation)
      raise ArgumentError, "#{annotation} is not a valid annotation"
    end

    context.alias_method :"__annotated_#{method_name}", method_name

    context.define_method method_name do
      send(annotation) { send(:"__annotated_#{method_name}") }
    end
  end
end
