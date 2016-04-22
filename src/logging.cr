require "logger"

module Artanis::Logging
  module ClassMethods
    # NOTE: until https://github.com/crystal-lang/crystal/issues/2458
    macro extended
      @@logger : Logger?
    end

    def logger
      @@logger ||= Logger.new(STDERR)
    end

    def logger=(@@logger : Logger)
    end
  end

  macro included
    extend ClassMethods
  end

  {% for constant in Logger::Severity.constants %}
    {% name = constant.downcase.id %}

    def {{name}}(message)
      self.class.logger.{{name}}(message)
    end

    def {{name}}
      self.class.logger.{{name}} { yield }
    end
  {% end %}
end
