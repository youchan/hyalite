module TransactionWrapper
  def init
  end

  def close
  end
end

class Transaction
  include TransactionWrapper

  def initialize(transaction_wrappers = nil, &block)
    @transaction_wrappers = transaction_wrappers || []
    if block_given?
      @close_proc = block
      @transaction_wrappers << self
    end
  end

  def close
    @close_proc.call
  end

  def close_all
    @transaction_wrappers.each do |wrapper|
      wrapper.close
    end
  end

  def init_all
    @transaction_wrappers.each do |wrapper|
      wrapper.init
    end
  end

  def perform
    init_all

    yield(self)
  ensure
    close_all
  end
end
