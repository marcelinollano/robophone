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
      bad_request
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
      @from    = params[:from]
      @contact = Contact.first(:id => params[:id])
      erb(:'contacts/edit')
    rescue
      bad_request
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
      contact.update(contact_from(params))
      redirect(params[:from])
    rescue
      bad_request
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
      bad_request
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
      bad_request
    end
  end

  get('/stories/new') do
    auth_basic!
    begin
      @from     = params[:from]
      @contacts = Contact.all
      @story    = Story.new
      @calls    = []
      erb(:'stories/new')
    rescue
      bad_request
    end
  end

  post('/stories') do
    auth_basic!
    begin
      story = Story.create(story_from(params))
      update_calls(story, params)
      redirect('/stories')
    rescue
      bad_request
    end
  end

  get('/stories/:id') do
    auth_basic!
    begin
      @story = Story.first(:id => params[:id])
      @calls = Call.where(:story_id => @story.id).order(:order)
      erb(:'stories/show')
    rescue
      bad_request
    end
  end

  get('/stories/:id/edit') do
    auth_basic!
    begin
      @from     = params[:from]
      @contacts = Contact.all
      @calls    = Call.order(:order)
      @story    = Story.first(:id => params[:id])
      erb(:'stories/edit')
    rescue
      bad_request
    end
  end

  get('/stories/:id/dial') do
    auth_basic!
    begin
      story = Story.first(:id => params[:id])
      Thread.new { system(`./bin/dial --id "#{story.id}"`) }
      redirect("/stories/#{params[:id]}")
    rescue
      bad_request
    end
  end

  get('/stories/:id/open') do
    auth_basic!
    begin
      story = Story.first(:id => params[:id])
      story.update({
        :status => 'open',
        :result => nil
      })
      redirect("/stories/#{params[:id]}")
    rescue
      bad_request
    end
  end

  get('/stories/:id/close') do
    auth_basic!
    # begin
      story  = Story.first(:id => params[:id])
      result = collect_result(story)
      story.update({
        :status => 'closed',
        :result => result
      })
      redirect("/stories/#{params[:id]}")
    # rescue
    #   bad_request
    # end
  end

  # This needs a Twilio phone number
  #
  # get('/stories/:id/sms') do
  #   auth_basic!
  #   begin
  #     story = Story.first(:id => params[:id])
  #     Thread.new { system(`./bin/sms --id "#{story.id}"`) }
  #     redirect("/stories/#{params[:id]}")
  #   rescue
  #     bad_request
  #   end
  # end

  put('/stories/:id') do
    auth_basic!
    begin
      story = Story.first(:id => params[:id])
      story.update(story_from(params))
      update_calls(story, params)
      redirect(params[:from])
    rescue
      bad_request
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
      bad_request
    end
  end

  delete('/call/:id') do
    auth_token!(params[:token])
    begin
      call = Call.find(:id => params[:id])
      call.destroy
      headers("Access-Control-Allow-Origin" => "*")
      return('true')
    rescue
      bad_request
    end
  end

  # Twiml

  get('/twiml/:id/call.xml') do
    begin
      @id       = params[:id]
      @text     = CGI.unescape(params[:text])
      @language = params[:language]
      @timeout  = params[:timeout]
      content_type('text/xml')
      erb(:"twiml/#{params[:template]}", :layout => false)
    rescue
      bad_request
    end
  end

  get('/twiml/:id/hangup.xml') do
    begin
      if params[:SpeechResult]
        call = Call.first(:id => params[:id])
        call.update(:transcript => params[:SpeechResult])
      end
      content_type('text/xml')
      erb(:'twiml/hangup', :layout => false)
    rescue
      bad_request
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
      auth.credentials == [ENV['APP_LOGIN'], ENV['APP_PASS']]
      response['WWW-Authenticate'] = %(Basic realm='Restricted area')
      unauthorized
    end
  end

  def auth_token!(token)
    unless token == ENV['APP_TOKEN']
      unauthorized
    end
  end

  def contact_from(params)
    {
      :name  => params[:name],
      :phone => params[:phone],
      :rings => params[:rings]
    }
  end

  def story_from(params)
    {
      :status      => params[:status],
      :title       => params[:title],
      :text        => params[:text],
      :phone       => params[:phone],
      :timeout     => params[:timeout],
      :language    => params[:language]
    }
  end

  def update_calls(story, params)
    calls = []
    params[:calls_ids].each_with_index do |id, i|
      calls << {:id => id, :contact_id => params[:contacts_ids][i] }
    end
    count = 1
    calls.each_with_index do |c|
      call = Call.first(:id => c[:id])
      opts = {
        :story_id => story.id,
        :contact_id => c[:contact_id],
        :order => count
      }
      if call
        if !c[:contact_id].strip.empty?
          call.update(opts)
          count = count + 1
        else
          call.destroy
        end
      else
        if !c[:contact_id].strip.empty?
          Call.create(opts)
          count = count + 1
        end
      end
    end
  end

  def collect_result(story)
    transcripts = Array.new
    story.calls.each_with_index do |call, i|
      transcripts << call.transcript if call.transcript
    end
    transcripts = transcripts.reject { |s| s.nil? || s.strip.empty? }

    if transcripts.length > 0
      result = String.new
      result << "#{story.title}: "
      result << "#{story.text} / "
      result <<  transcripts.join(' / ')
      result << "."
      result = URI.encode(result)
      return(result)
    else
      return(nil)
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
