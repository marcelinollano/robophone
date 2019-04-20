require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

require './db.rb'

class App < Sinatra::Base

  get('/contacts/?') do
    erb :contacts
  end

  post('/contact/:id/?') do
  end

  delete('/contact/?') do
    auth_token!(params[:token])
    begin
      contact = Contact.find(:permalink => params[:permalink])
      contact.destroy
      headers("Access-Control-Allow-Origin" => "*")
      'true'
    rescue
      not_found
    end
  end

  get('/story/:permalink/?') do
    erb :story
  end

  get('/?') do
    auth_basic!
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
