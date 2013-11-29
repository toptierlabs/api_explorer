class UsersController < ApplicationController
  layout false
  def index
    render :json => { :message => 'It works!'}
  end
end
