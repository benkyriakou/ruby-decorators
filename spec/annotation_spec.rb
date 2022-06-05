# frozen_string_literal: true

require "annotation"

RSpec.describe Annotation do
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

  context "annotated class" do
    subject(:annotated_class) do
      base_class.class_eval do
        extend Annotation

        def self.upcase
          yield.upcase
        end

        annotate_method :bar, :upcase

        def wrap
          ">>> #{yield} <<<"
        end

        annotate_method :foo, :wrap
      end

      base_class
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
    subject(:annotated_class) do
      base_class.class_eval do
        extend Annotation

        def self.upcase
          yield.upcase
        end

        annotate_method :qux, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { annotated_class }.to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "annotating nonexistent instance method" do
    subject(:annotated_class) do
      base_class.class_eval do
        extend Annotation

        def upcase
          yield.upcase
        end

        annotate_method :qux, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { annotated_class }.to raise_error(ArgumentError, "qux is not a class or instance method")
    end
  end

  context "applying nonexistent class method annotation" do
    subject(:annotated_class) do
      base_class.class_eval do
        extend Annotation

        annotate_method :bar, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { annotated_class }.to raise_error(ArgumentError, "upcase is not a valid annotation")
    end
  end

  context "applying nonexistent instance method annotation" do
    subject(:annotated_class) do
      base_class.class_eval do
        extend Annotation

        annotate_method :foo, :upcase
      end

      base_class
    end

    it "raises an exception" do
      expect { annotated_class }.to raise_error(ArgumentError, "upcase is not a valid annotation")
    end
  end
end
