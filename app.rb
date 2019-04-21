require 'cgi'
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
    begin
      @contact  = Contact.new
      @contacts = Contact.all
      erb(:'contacts/index')
    rescue
      not_found
    end
  end

  get('/contacts/new') do
    auth_basic!
    begin
      @contact  = Contact.new
      erb(:'contacts/new')
    rescue
      bad_request
    end
  end

  get('/contacts/:id/edit') do
    auth_basic!
    begin
      @contact = Contact.first(:id => params[:id])
      erb(:'contacts/edit')
    rescue
      not_found
    end
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
    begin
      @story = Story.new
      @stories = Story.all
      erb(:'stories/index')
    rescue
      not_found
    end
  end

  get('/stories/new') do
    auth_basic!
    begin
      @from  = params[:from]
      @story = Story.new
      erb(:'stories/new')
    rescue
      bad_request
    end
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
    begin
      @story = Story.first(:id => params[:id])
      erb(:'stories/show')
    rescue
      not_found
    end
  end

  get('/stories/:id/edit') do
    auth_basic!
    begin
      @from  = params[:from]
      @story = Story.first(:id => params[:id])
      erb(:'stories/edit')
    rescue
      not_found
    end
  end

  get('/stories/:id/dial') do
    auth_basic!
    begin
      story = Story.first(:id => params[:id])

      from = '+34646446543'
      to   = '+34673300601'
      text = story.beginning

      Thread.new { system(`./bin/dial --from "#{from}" --to "#{to}" --text "#{text}"`) }
    rescue
      not_found
    end
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
      redirect(params[:from])
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

  # Voice

  get('/voice.xml') do
    auth_token!(params[:token])
    if params[:text] && !params[:text].strip.empty?
      @text = CGI.unescape(params[:text])
      content_type('text/xml')
      erb(:'voices/default', :layout => false)
    else
      content_type('text/xml')
      erb(:'voices/error', :layout => false)
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
