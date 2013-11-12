
module ApiExplorer
  class Engine < ::Rails::Engine
    isolate_namespace ApiExplorer
    
   
  end

  def self.config(&block)
    yield Engine.config if block
    Engine.config
  end
end
