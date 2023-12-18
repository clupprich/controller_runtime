require "test_helper"
require "rack/test"
require "railsfile"

class TestRailsfile < Minitest::Test
  include Rack::Test::Methods

  def setup
    @io = StringIO.new
    ActionController::Base.logger = ActiveSupport::Logger.new(@io)
  end

  def app
    Rails.application
  end

  def test_something
    get "/books"

    assert_match %r{Completed 200 OK in .* | Example: \d{3}.\d+ms |}, @io.string

    assert last_response.ok?
  end
end
