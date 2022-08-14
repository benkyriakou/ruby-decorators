# ruby-annotations

## Disclaimer

This is more of an exercise in metaprogramming than any kind of stable code, so you probably shouldn't use this for anything other than amusement.

This provides some loosely Python-style decorators for Ruby classes, by abusing method aliasing and TracePoints. There are two types of decorator you can use:

## Runtime decorator

```ruby
require "decorators"

class MyClass
  extend Decorators::Decorator
  
  def self.hello
    p "hello"
  end
  
  def self.upcase
    yield.upcase
  end
  
  decorate_method :hello, :upcase
end

MyClass.hello # prints "HELLO"
```

## Lazy decorator

This makes use of the TracePoint module to allow the decorator to be evaluated when it's invoked rather than at runtime, so the decorator can be placed before the method.

```ruby
require "decorators"

class MyClass
  extend Decorators::LazyDecorator

  decorate_method :hello, :upcase
  def self.hello
    p "hello"
  end
  
  def self.upcase
    yield.upcase
  end
end

MyClass.hello # prints "HELLO"
```
