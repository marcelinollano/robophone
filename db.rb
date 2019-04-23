Sequel::Model.plugin(:update_or_create)
DB = Sequel.connect("sqlite://db/#{ENV['RACK_ENV']}.sqlite3")
DB.extension(:pagination)

# Contacts

DB.create_table?(:contacts) do
  primary_key :id
  String   :name
  String   :phone
  Integer  :rings
  DateTime :created_at
  DateTime :updated_at
  index    :id, :unique => true
end

class Contact < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  one_to_many :calls
  plugin(:association_dependencies, :calls => :destroy)

  def validate
    super
    validates_presence([:name, :phone, :rings])
    validates_unique(:phone)
    validates_numeric(:rings)
    errors.add(:phone, 'invalid') if Phonelib.invalid_for_country?(self.phone, 'ES')
  end
end

# Stories

DB.create_table?(:stories) do
  primary_key :id
  String   :name
  String   :text
  String   :phone
  String   :language
  Integer  :record_time
  DateTime :created_at
  DateTime :updated_at
  index    :id, :unique => true
end

class Story < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  one_to_many :calls
  plugin(:association_dependencies, :calls => :destroy)

  def validate
    super
    validates_presence([:name, :text, :phone, :record_time, :language])
    validates_unique([:name, :text])
    if Phonelib.invalid_for_country?(self.phone, ENV['DEFAULT_LANGUAGE'][-2..-1])
      errors.add(:phone, "#{self.phone}")
    end
  end
end

# Calls

DB.create_table?(:calls) do
  primary_key :id
  foreign_key :story_id, :stories
  Integer  :order
  Integer  :duration
  String   :recording
  String   :transcript
  String   :status
  DateTime :created_at
  DateTime :updated_at
  Integer  :contact_id
  index    :id, :unique => true
end

class Call < Sequel::Model
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)
  many_to_one :story
  many_to_one :contact
end
