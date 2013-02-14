module Statify
  module Matchers
    def register_collection(collection_name)
      RegisterCollectionMatcher.new(collection_name)
    end
    
    class RegisterCollectionMatcher
      def initialize(collection_name)
        @collection_name = collection_name
      end

      def matches?(subject)
        @actual_model = subject.class.name
        subject.class.collection_registered? @collection_name
      end

      def failure_message
        "Expected #{@actual_model} to have registered a collection on #{@collection_name}."
      end

      def negative_failure_message
        "Didn't expect #{@actual_model} to have registered a collection on #{@collection_name}."
      end

      def description
        "have registered a collection on #{@collection_name}"
      end
    end
  end
end