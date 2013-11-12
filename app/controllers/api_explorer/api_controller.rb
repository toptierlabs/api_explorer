require_dependency "api_explorer/application_controller"

module ApiExplorer
  class ApiController < ApplicationController
    before_filter :read_file

    def index
      json_string = ''

      
    
    end

    def method
      @method = @methods[params[:position].to_i - 1]

      render :json=> {
        :parameters_html=> (
          render_to_string("api_explorer/api/parameters", :locals=>{:parameters=>@method['parameters']} ,:layout => false)
          ), :description=>@method['description']
      }
    end

    def execute
      require 'net/http'

      http = Net::HTTP.new(request.host, request.port) 
      request = Net::HTTP::Get.new('/api_explorer' + params[:url]) 
      request.set_form_data( params.except([:action, :controller]) )
      response = http.request(request)

      render :json =>{ :response=> response.body}, :layout=>false
    end
  protected
    def read_file
      if ApiExplorer::use_file
        json_path = ApiExplorer::json_path
        json_string = File.read(json_path)
      else
        json_string = ApiExplorer::json_string
      end
       
      @methods = JSON.parse(json_string)["methods"]
    end
  end
end
