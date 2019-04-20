require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

require './db.rb'

class App < Sinatra::Base

  get('/contacts') do
    auth_basic!
    @contacts = Contact.all
    erb :contacts
  end

  post('/contact/new') do
    auth_basic!
    begin
      Contact.create(params)
      redirect '/contacts'
    rescue
      bad_request
    end
  end

  post('/contact/:id') do
    auth_basic!
  end

  delete('/contact/:id') do
    auth_token!(params[:token])
    begin
      contact = Contact.find(:id => params[:id])
      contact.destroy
      headers("Access-Control-Allow-Origin" => "*")
      'true'
    rescue
      not_found
    end
  end

  get('/story/:permalink') do
    auth_basic!
    erb :story
  end

  get('/') do
    auth_basic!
    @stories = Story.all
    erb :stories
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
