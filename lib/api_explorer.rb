require "api_explorer/engine"

module ApiExplorer
  mattr_accessor :json_string
  mattr_accessor :json_path
  mattr_accessor :use_file 

  self.use_file = true
  self.json_path = '/lib/file.json'

end
