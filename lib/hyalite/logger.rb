module Hyalite
  module Logger
    ERROR_LEVELS = %i(error warn info debug)

    def self.log_level=(level)
      @log_level_index = ERROR_LEVELS.index(level)
    end

    def self.log_level
      @log_level_index ||= ERROR_LEVELS.index(:warn)
      ERROR_LEVELS[@log_level_index]
    end

    def self.error(obj)
      if self.log_level == :error
        output(:error, obj)
      end
    end

    def self.warn(obj)
      if @log_level_index <=  ERROR_LEVELS.index(:warn)
        output(:warn, obj)
      end
    end

    def self.info(obj)
      if @log_level_index <=  ERROR_LEVELS.index(:info)
        output(:info, obj)
      end
    end

    def self.debug(obj)
      output(:debug, obj)
    end

    def self.output(level, obj)
      case obj
      when String
        puts "#{level.upcase}: #{obj}"
      else
        puts "#{level.upcase}: #{obj.inspect}"
      end
    end
  end
end
