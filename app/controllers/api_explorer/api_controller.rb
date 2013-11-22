require_dependency "api_explorer/application_controller"

module ApiExplorer
  class ApiController < ApplicationController
    before_filter :read_file

    def index

    end

    def method
      @method = @methods[params[:position].to_i - 1]

      render :json=> {
        :parameters_html=> (
          render_to_string("api_explorer/api/parameters", :locals=>{:parameters=>@method['parameters'], :values=>session} ,:layout => false)
          ), :description=>@method['description']
      }
    end

    def execute
      require 'net/http'
      require 'coderay'
      headers = params[:header][:name].zip(params[:header][:value])
      headers.select!{|header| !header[0].empty? && !header[1].empty?}
      
      headers.map!{|header| {:name=> header[0], :value=> header[1]}}
      
      uri = URI::HTTP.build(:host=>request.host, :port=> request.port, :path=>'/' + params[:url])
      http = Net::HTTP.new(uri.host, uri.port) 

      if params[:method].upcase == 'GET'
        request = Net::HTTP::Get.new(uri.request_uri) 
      elsif params[:method].upcase == 'POST'
        request = Net::HTTP::Post.new(uri.request_uri) 
      elsif params[:method].upcase == 'PUT'
        request = Net::HTTP::Put.new(uri.request_uri) 
      elsif params[:method].upcase == 'DELETE'
        request = Net::HTTP::Delete.new(uri.request_uri) 
      end
      

      form_hash = params.except([:action, :controller, :header, :authentication_type, :auth])
      form_hash.keys.each do |key|
        session['api_explorer_' + key.to_s] = form_hash[key]
      end      

      request.set_form_data( form_hash )
      headers.each do |header|
        request[header[:name]] = header[:value]
      end
      if params[:authentication_type] == 'basic_auth'
        request.basic_auth params[:auth][:basic_auth_user], params[:auth][:basic_auth_password]
      elsif params[:authentication_type] == 'hash_url_auth'
        string_to_convert = uri.to_s
        hash_verification = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), params[:auth][:secret_key], string_to_convert)).strip
        request[params[:auth][:header_field]] = hash_verification
      end


      response = http.request(request)

      raw_response = response.body
      response_html = ''

      if response.header['Content-Type'].include? 'application/json'
        tokens = CodeRay.scan(JSON.pretty_generate(JSON.parse(raw_response)), :json)
        response_html = tokens.div
      elsif response.header['Content-Type'].include? 'application/xml'
        tokens = CodeRay.scan(raw_response, :xml)
        response_html = tokens.div
      elsif response.header['Content-Type'].include? 'text/html'
        tokens = CodeRay.scan(raw_response, :html)
        response_html = tokens.div
      else
        response_html = '<div>' + raw_response + '</div>'
      end

      request_html = CodeRay.scan(request.to_yaml, :yaml).div


      curr_time = DateTime.now
      timestamp = curr_time.strftime('%Y%m%d%H%M%S%L')
      
      history_html = render_to_string 'api_explorer/api/history', :locals=>{:request_html=>request_html, 
        :response_html=>response_html, :timestamp=>timestamp}, :layout=>false

      

      render :json =>{ :response_html=> response_html , :request_html => request_html, 
        :history_html=>history_html, :date=> curr_time.strftime('%H:%M:%S'), 
        :timestamp => timestamp,
        :http_method=>params[:method].upcase, :request_url=>params[:url]
      } , :layout=>false
          
    end
  protected
    def read_file
      json_string = ''
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
