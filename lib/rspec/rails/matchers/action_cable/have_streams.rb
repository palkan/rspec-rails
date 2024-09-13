module RSpec
  module Rails
    module Matchers
      module ActionCable
        # @api private
        # Provides the implementation for `have_stream`, `have_stream_for`, and `have_stream_from`.
        # Not intended to be instantiated directly.
        class HaveStream < RSpec::Matchers::BuiltIn::BaseMatcher
          # @api private
          # @return [String]
          def failure_message
            "expected to have #{base_message}"
          end

          # @api private
          # @return [String]
          def failure_message_when_negated
            "expected not to have #{base_message}"
          end

          # @api private
          # @return [Boolean]
          def matches?(subscription)
            raise(ArgumentError, "have_streams is used for negated expectations only") if no_expected?

            match(subscription)
          end

          # @api private
          # @return [Boolean]
          def does_not_match?(subscription)
            !match(subscription)
          end

        private

          def match(subscription)
            case subscription
            when ::ActionCable::Channel::Base
              @actual = streams_for(subscription)
              no_expected? ? actual.any? : actual.any? { |i| expected === i }
            else
              raise ArgumentError, "have_stream, have_stream_from and have_stream_from support expectations on subscription only"
            end
          end

          def base_message
            no_expected? ? "any stream started" : "stream #{expected_formatted} started, but have #{actual_formatted}"
          end

          def no_expected?
            !defined?(@expected)
          end

          def streams_for(subscription)
            # In Rails 8, subscription.streams returns a real subscriptions hash,
            # not a fake array of stream names like in Rails 6-7.
            # So, we must use #stream_names instead.
            subscription.respond_to?(:stream_names) ? subscription.stream_names : subscription.streams
          end
        end
      end
    end
  end
end
