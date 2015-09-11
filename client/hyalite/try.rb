class Object
  def try
    unless self.nil?
      yield self
    end
  end
end
