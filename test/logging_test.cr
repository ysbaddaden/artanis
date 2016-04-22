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

  def io
    @io ||= MemoryIO.new
  end

  def setup
    LogApp.logger = Logger.new(io)
    LogApp.logger.level = Logger::Severity::DEBUG
  end

  def test_debug
    LogApp.call(context("GET", "/debug"))
    assert_match /this is a debug message$/, io.to_s
  end

  def test_info
    LogApp.call(context("GET", "/info"))
    assert_match /some info message$/, io.to_s
  end
end
