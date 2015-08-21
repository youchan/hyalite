class CallbackQueue
  def initialize
    @queue = []
  end

  def enqueue(proc = nil)
    if proc.nil? && block_given?
      proc = Proc.new { yield }
    end
    @queue << proc
  end

  def notify_all
    queue = @queue
    @queue = []
    while queue.length > 0
      proc = queue.shift
      proc.call
    end
  end
end
