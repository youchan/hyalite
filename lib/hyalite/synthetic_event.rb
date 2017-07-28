module Hyalite
  class SyntheticEvent
    attr_reader :event

    def initialize(event)
      @event = event
      @listeners = []
    end

    def add_listener(listener, target_id)
      @listeners << [listener, target_id]
    end

    def each_listener(&block)
      @listeners.each {|listener| yield(listener) }
    end
  end
end
