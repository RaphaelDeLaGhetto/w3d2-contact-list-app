require 'csv'
require 'pg'

# Represents a person in an address book.
class Contact

  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  def save
    self.class.connection.exec_params('INSERT INTO contacts (name, email) VALUES ($1, $2)', [@name, @email])
  end

  # Provides functionality for managing a list of Contacts in a database.
  class << self

    # Returns an Array of Contacts loaded from the database.
    def all
      contacts = []
      self.connection.exec('SELECT name, email FROM contacts') do |result|
        contacts = result.values
      end
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    def create(name, email)
      new(name, email).save
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id=nil)
      record = self.connection.exec_params('SELECT * FROM contacts WHERE id = $1::int', [id]) if id.is_a?(Integer)
      record.nil? || record.num_tuples.zero? ? nil : record[0].values
    end

    # Returns an array of contacts who match the given term.
    def search(term=nil)
      return [] if term.nil? || term.empty?
      self.connection.exec("SELECT * FROM contacts WHERE name ILIKE '%#{term}%' OR email ILIKE '%#{term}%'").values
    end

    # Get the postgres connection object
    def connection
      return @conn if @conn
      @conn = PG.connect(dbname: 'contacts')
    end
  end
end
