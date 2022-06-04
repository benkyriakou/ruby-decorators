require "pry-byebug"

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
    __annotate_method(method_name, annotation)
  end

  # Here we can abuse class_eval since singleton methods are instance methods on the singleton class.
  def annotate_class_method(method_name, annotation)
    singleton_class.class_eval do
      alias_method :"__annotated_#{method_name}", method_name

      define_method method_name do
        send(annotation) { send(:"__annotated_#{method_name}") }
      end
    end
  end

  def __annotate_method(method_name, annotation)
    alias_method :"__annotated_#{method_name}", method_name

    define_method method_name do
      send(annotation) { send(:"__annotated_#{method_name}") }
    end
  end
end

class SomeObject
  extend Annotation

  def self.hello
    puts "hello"
    yield
    puts "world"
  end

  def self.my_method
    puts "bar"
  end

  # Could allow this to be used anywhere with singleton_method_added...
  annotate_method :my_method, :hello

  def butts
    puts "butts"
    yield
  end

  def foo
    puts "foo"
  end

  annotate_method :foo, :butts
end

SomeObject.my_method
SomeObject.new.foo