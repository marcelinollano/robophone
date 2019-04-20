require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

require './db.rb'

class App < Sinatra::Base
  configure do
    enable(:method_override)
  end

  helpers do
    def active?(path='')
      request.path_info == path ? 'active' : nil
    end
  end

  # Contacts

  get('/contacts') do
    auth_basic!
    @contact  = Contact.new
    @contacts = Contact.all
    erb(:'contacts/index')
  end

  get('/contacts/new') do
    auth_basic!
    @contact  = Contact.new
    erb(:'contacts/new')
  end

  get('/contacts/:id/edit') do
    auth_basic!
    @contact = Contact.first(:id => params[:id])
    erb(:'contacts/edit')
  end

  post('/contacts') do
    auth_basic!
    begin
      Contact.create(params)
      redirect('/contacts')
    rescue
      bad_request
    end
  end

  put('/contacts/:id') do
    auth_basic!
    begin
      contact = Contact.first(:id => params[:id])
      contact.update({
        :name  => params[:name],
        :phone => params[:phone],
        :rings => params[:rings],
      })
      redirect('/contacts')
    rescue
      not_found
    end
  end

  delete('/contacts/:id') do
    auth_token!(params[:token])
    begin
      contact = Contact.find(:id => params[:id])
      contact.destroy
      headers("Access-Control-Allow-Origin" => "*")
      return('true')
    rescue
      not_found
    end
  end

  # Stories

  get('/stories') do
    auth_basic!
    @story = Story.new
    @stories = Story.all
    erb(:'stories/index')
  end

  get('/stories/new') do
    auth_basic!
    @story = Story.new
    erb(:'stories/new')
  end

  post('/stories') do
    auth_basic!
    begin
      Story.create(params)
      redirect('/stories')
    rescue
      bad_request
    end
  end

  get('/stories/:id') do
    auth_basic!
    @story = Story.first(:id => params[:id])
    erb(:'stories/show')
  end

  get('/stories/:id/edit') do
    auth_basic!
    @story = Story.first(:id => params[:id])
    erb(:'stories/edit')
  end

  put('/stories/:id') do
    auth_basic!
    begin
      story = Story.first(:id => params[:id])
      story.update({
        :name        => params[:name],
        :beginning   => params[:beginning],
        :queued      => params[:queued],
        :ringing     => params[:ringing],
        :in_progress => params[:in_progress],
        :size        => params[:size]
      })
      redirect('/stories')
    rescue
      not_found
    end
  end

  delete('/stories/:id') do
    auth_token!(params[:token])
    begin
      story = Story.find(:id => params[:id])
      story.destroy
      headers("Access-Control-Allow-Origin" => "*")
      return('true')
    rescue
      not_found
    end
  end

  # Root

  get('/') do
    auth_basic!
    redirect('/stories')
  end

private

  def auth_basic!
    auth ||=  Rack::Auth::Basic::Request.new(request.env)
    unless auth.provided? &&
      auth.basic? &&
      auth.credentials &&
      auth.credentials == [ENV['LOGIN'], ENV['PASS']]
      response['WWW-Authenticate'] = %(Basic realm='Restricted area')
      unauthorized
    end
  end

  def auth_token!(token)
    unless token == ENV['TOKEN']
      unauthorized
    end
  end

  def bad_request
    halt(400, 'Bad Request')
  end

  def unauthorized
    halt(401, 'Unauthorized')
  end

  def not_found
    halt(404, 'Not Found')
  end
end
