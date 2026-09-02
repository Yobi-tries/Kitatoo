ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Minitest 6 dropped Minitest::Mock / Object#stub, and this project has no
    # mocking gem. This is a minimal replacement for the common case of
    # stubbing a single singleton method (e.g. RubyLLM.paint,
    # Cloudinary::Uploader.upload) for the duration of a block.
    def stub_singleton_method(receiver, method_name, replacement)
      original = receiver.method(method_name)
      receiver.define_singleton_method(method_name, &replacement)
      yield
    ensure
      receiver.define_singleton_method(method_name, original)
    end
  end
end
