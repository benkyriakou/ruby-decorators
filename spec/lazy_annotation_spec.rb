# frozen_string_literal: true

RSpec.describe Annotations::LazyAnnotation do
  subject(:base_class) do
    # @todo Find a nicer way of not getting overlaps between tests.
    #       Using class_eval doesn't seem to play nice with TracePoints.
    if Object.const_defined?(:MyLazyClass)
      Object.send(:remove_const, :MyLazyClass)
    end

    class MyLazyClass
      def self.bar
        "bar"
      end

      def foo
        "foo"
      end
    end

    MyLazyClass
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

  context "annotated class" do
    let(:annotated_class) do
      base_class

      class MyLazyClass
        extend Annotations::LazyAnnotation

        annotate_method :bar, :test

        def self.test
          yield.upcase
        end

        annotate_method :foo, :wrap

        def wrap
          ">>> #{yield} <<<"
        end
      end

      MyLazyClass
    end

    describe "#bar" do
      subject { annotated_class.bar }

      it { is_expected.to eq("BAR") }
    end

    describe ".foo" do
      subject { annotated_class.new.foo }

      it { is_expected.to eq(">>> foo <<<") }
    end
  end

  context "annotating nonexistent class method" do
    let(:annotated_class) do
      base_class

      class MyLazyClass
        extend Annotations::LazyAnnotation

        annotate_method :qux, :upcase

        def self.upcase
          yield.upcase
        end
      end

      MyLazyClass
    end

    it "raises an exception" do
      expect { annotated_class }.
        to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "annotating nonexistent instance method" do
    let(:annotated_class) do
      base_class

      class MyLazyClass
        extend Annotations::LazyAnnotation

        annotate_method :qux, :upcase

        def upcase
          yield.upcase
        end
      end

      MyLazyClass
    end

    it "raises an exception" do
      expect { annotated_class }.
        to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "applying nonexistent class method annotation" do
    let(:annotated_class) do
      base_class

      class MyLazyClass
        extend Annotations::LazyAnnotation

        annotate_method :bar, :upcase
      end

      MyLazyClass
    end

    it "raises an exception" do
      expect { annotated_class }.
        to raise_error(ArgumentError, "upcase is not a valid annotation")
    end
  end

  context "applying nonexistent instance method annotation" do
    subject(:annotated_class) do
      base_class

      class MyLazyClass
        extend Annotations::LazyAnnotation

        annotate_method :foo, :upcase
      end

      MyLazyClass
    end

    it "raises an exception" do
      expect { annotated_class }.
        to raise_error(ArgumentError, "upcase is not a valid annotation")
    end
  end
end
