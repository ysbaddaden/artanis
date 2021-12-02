require "log"

module Artanis::Logging
  module ClassMethods
    # NOTE: until https://github.com/crystal-lang/crystal/issues/2458
    macro extended
      @@logger : Log?
    end

    def logger
      @@logger ||= Log.for("artanis")
    end

    def logger=(@@logger : Log)
    end
  end

  macro included
    extend ClassMethods
  end

  {% for constant in Log::Severity.constants %}
    {% name = constant.downcase.id %}

    def {{name}}(message)
      self.class.logger.{{name}} { message }
    end

    def {{name}}
      self.class.logger.{{name}} { yield }
    end
  {% end %}
end
