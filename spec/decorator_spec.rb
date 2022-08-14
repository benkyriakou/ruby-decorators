# frozen_string_literal: true

RSpec.describe Decorators::Decorator do
  subject(:base_class) do
    Class.new do
      def self.bar
        "bar"
      end

      def foo
        "foo"
      end
    end
  end

  context "base class" do
    describe "#bar" do
      subject { base_class.bar }

      it { is_expected.to eq("bar") }
    end

    describe ".foo" do
      subject { base_class.new.foo }

      it { is_expected.to eq("foo") }
    end
  end

  context "decorated class" do
    subject(:decorated_class) do
      base_class.class_eval do
        extend Decorators::Decorator

        def self.upcase
          yield.upcase
        end

        decorate_method :bar, :upcase

        def wrap
          ">>> #{yield} <<<"
        end

        decorate_method :foo, :wrap
      end

      base_class
    end

    describe "#bar" do
      subject { decorated_class.bar }

      it { is_expected.to eq("BAR") }
    end

    describe ".foo" do
      subject { decorated_class.new.foo }

      it { is_expected.to eq(">>> foo <<<") }
    end
  end

  context "decorating nonexistent class method" do
    subject(:decorated_class) do
      base_class.class_eval do
        extend Decorators::Decorator

        def self.upcase
          yield.upcase
        end

        decorate_method :qux, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { decorated_class }.to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "decorating nonexistent instance method" do
    subject(:decorated_class) do
      base_class.class_eval do
        extend Decorators::Decorator

        def upcase
          yield.upcase
        end

        decorate_method :qux, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { decorated_class }.to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "applying nonexistent class method decorator" do
    subject(:decorated_class) do
      base_class.class_eval do
        extend Decorators::Decorator

        decorate_method :bar, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { decorated_class }.to raise_error(ArgumentError, "upcase is not a valid decorator")
    end
  end

  context "applying nonexistent instance method decorator" do
    subject(:decorated_class) do
      base_class.class_eval do
        extend Decorators::Decorator

        decorate_method :foo, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { decorated_class }.to raise_error(ArgumentError, "upcase is not a valid decorator")
    end
  end
end
