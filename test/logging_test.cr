require "./test_helper"
require "../src/logging"

class Artanis::LoggingTest < Minitest::Test
  class LogApp < Artanis::Application
    include Artanis::Logging

    get "/debug" do
      debug "this is a debug message"
      "DEBUG"
    end

    get "/info" do
      info "some info message"
      "DEBUG"
    end
  end

  private def backend
    @backend ||= Log::MemoryBackend.new
  end

  def setup
    LogApp.logger = Log.for("log_app")
    Log.setup("log_app", :debug, backend)
  end

  def test_debug
    LogApp.call(context("GET", "/debug"))
    assert_equal ["this is a debug message"], backend.entries.map(&.message)
  end

  def test_info
    LogApp.call(context("GET", "/info"))
    assert_equal ["some info message"], backend.entries.map(&.message)
  end
end
