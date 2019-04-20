require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

Sequel::Model.plugin(:update_or_create)
DB = Sequel.connect("sqlite://db/#{ENV['RACK_ENV']}.sqlite3")
DB.extension(:pagination)

# Contacts

DB.create_table?(:contacts) do
  primary_key :id
  String   :name
  String   :phone
  Integer  :pings
  DateTime :created_at
  DateTime :updated_at
  index    :id, :unique => true
end

class Contact < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  one_to_many :posts

  def validate
    super
    validates_presence([:name, :phone])
    validates_unique(:phone)
    validates_numeric(:pings)
    if Phonelib.invalid_for_country?(self.phone, 'ES')
      errors.add(:phone, 'invalid')
    end
  end

  def before_validation
    super
    self.pings ||= 0
  end
end

# Stories

DB.create_table?(:stories) do
  primary_key :id
  String   :name
  String   :permalink
  String   :beginning
  Integer  :time_queued
  Integer  :time_ringing
  Integer  :time_in_progress
  DateTime :created_at
  DateTime :updated_at
  index    :id, :unique => true
end

class Story < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  one_to_many :posts

  def validate
    super
    validates_presence([:name, :permalink])
    validates_unique([:name, :permalink])
  end
end

# Posts

DB.create_table?(:posts) do
  primary_key :id
  foreign_key :story_id,   :stories
  foreign_key :contact_id, :contacts
  String   :status
  String   :audio
  String   :transcript
  DateTime :created_at
  DateTime :updated_at
  index    :id, :unique => true
end

class Post < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  many_to_one :story
  many_to_one :contact

  def validate
    super
    validates_presence([:audio, :transcript])
  end
end

# Seeds

# services = [{
#   :permalink => 'https://instagram.com',
#   :name => 'Instagram'
# }]
#
# services.each do |service|
#   Service.update_or_create({
#     :permalink => service[:permalink],
#     :name      => service[:name],
#     :slug      => service[:name].to_slug.normalize.to_s
#   })
# end
