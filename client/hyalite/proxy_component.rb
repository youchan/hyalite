class ProxyComponent
  include Component
  include Component::ShortHand

  def self.render_proc=(proc)
    @render_proc = proc
  end

  def self.render_proc
    @render_proc
  end

  def render
    self.instance_exec(@props, &self.class.render_proc)
  end
end
