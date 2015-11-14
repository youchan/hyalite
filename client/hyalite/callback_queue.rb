class CallbackQueue
  def initialize
    @queue = []
  end

  def enqueue(proc = nil, &block)
    if proc
      @queue << proc
    elsif block_given?
      @queue << block
    end
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
