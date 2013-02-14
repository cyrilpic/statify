module Statify
  module Matchers
    def have_registered_collection_on(collection_name)
      HaveRegisteredCollectionOnMatcher.new(collection_name)
    end
    
    class HaveRegisteredCollectionOnMatcher
      def initialize(collection_name)
        @collection_name = collection_name
      end

      def matches?(subject)
        @actual_model = subject.class.name
        subject.collection_registered? @collection_name
      end

      def failure_message
        "Expected #{actual_model} to have registered a collection on #{@collection_name}."
      end

      def negative_failure_message
        "Didn't expect #{actual_model} to have registered a collection on #{@collection_name}."
      end

      def description
        "have registered a collection on #{@collection_name}"
      end
    end
  end
end