require_dependency "api_explorer/application_controller"

module ApiExplorer
  class ApiController < ApplicationController
    before_filter :read_file
    
    def index

    end

    def method
      # A method has been selected
      @method = @methods[params[:position].to_i - 1]

      #Reading parameters and sending to the frontend
      render :json=> {
        :parameters_html=> (
          render_to_string("api_explorer/api/parameters", :locals=>{:parameters=>@method['parameters'], :values=>session} ,:layout => false)
          ), :description=>@method['description']
      }
    end

    def execute
      require 'net/http'
      require 'coderay'

      # Build the headers array
      headers = params[:header][:name].zip(params[:header][:value])
      headers.select!{|header| !header[0].empty? && !header[1].empty?}
      headers.map!{|header| {:name=> header[0], :value=> header[1]}}
      
      # Initialize HTTP request
      uri = URI::HTTP.build(:host=>request.host, :port=> request.port, :path=>'/' + params[:url])
      http = Net::HTTP.new(uri.host, uri.port) 

      if params[:method].upcase == 'GET'
        request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' =>'application/json'}) 
      elsif params[:method].upcase == 'POST'
        request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'}) 
      elsif params[:method].upcase == 'PUT'
        request = Net::HTTP::Put.new(uri.request_uri, {'Content-Type' =>'application/json'}) 
      elsif params[:method].upcase == 'DELETE'
        request = Net::HTTP::Delete.new(uri.request_uri, {'Content-Type' =>'application/json'}) 
      end
      
      # Store parameters on session
      form_hash = params.except([:action, :controller, :header, :authentication_type, :auth])
      
      form_hash.keys.each do |key|
        if form_hash[key].is_a?(Hash)
          h_and_key = to_form_name({ key=> form_hash[key] } ).split("=")
          session['api_explorer_' + h_and_key.first] = h_and_key.second
        else
          session['api_explorer_' + key.to_s] = form_hash[key] 
        end
      end      
      
      
      # Set form data and headers
      request.body = form_hash.to_hash.to_json

      #request.set_form_data( to_http_params(form_hash) )
      headers.each do |header|
        request[header[:name]] = header[:value]
      end

      # Set authentication method
      if params[:authentication_type] == 'basic_auth'
        request.basic_auth params[:auth][:basic_auth_user], params[:auth][:basic_auth_password]
      elsif params[:authentication_type] == 'hash_url_auth'
        string_to_convert = uri.to_s
        hash_verification = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), params[:auth][:secret_key], string_to_convert)).strip
        request[params[:auth][:header_field]] = hash_verification
      end

      # Make request
      response = http.request(request)
      raw_response = response.body
      response_html = ''

      # Parse response and beautify the response
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

      # Parse and beautify request information
      request_html = CodeRay.scan(request.to_yaml, :yaml).div

      # Get timestamp
      curr_time = DateTime.now
      timestamp = curr_time.strftime('%Y%m%d%H%M%S%L')
      
      # Generate HTML for history
      history_html = render_to_string 'api_explorer/api/history', :locals=>{:request_html=>request_html, 
        :response_html=>response_html, :timestamp=>timestamp}, :layout=>false

      
      # Respond json request
      render :json =>{ :response_html=> response_html , :request_html => request_html, 
        :history_html=>history_html, :date=> curr_time.strftime('%H:%M:%S'), 
        :timestamp => timestamp,
        :http_method=>params[:method].upcase, :request_url=>params[:url]
      } , :layout=>false
          
    end
  protected

    def to_form_name(hash, rec=nil)
      hmap = hash.map do |k, v|
        wrap_left = !rec.nil? ? "[" : ""
        wrap_right = !rec.nil? ? "]" : ""

        if v.is_a?(Hash)
          "#{wrap_left}#{k}#{wrap_right}" + to_form_name(v, true)
        else
          "#{wrap_left}#{k}#{wrap_right}=#{v}"
        end
      end

      if rec
        hmap.first
      else
        hmap.join('&')
      end
    end


    # Read file with methods
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
