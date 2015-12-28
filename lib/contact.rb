require 'csv'
require 'pg'

# Represents a person in an address book.
class Contact

  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  # Provides functionality for managing a list of Contacts in a database.
  class << self

    # Returns an Array of Contacts loaded from the database.
    def all
      contacts = []
#      conn = self.connection
      self.connection.exec('SELECT name, email FROM contacts') do |result|
        contacts = result.values
      end
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    def create(name, email)
      CSV.open("data/contacts.csv", "ab") do |csv|
        csv << [name, email]
      end
      new(name, email)
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id=nil)
      record = CSV.open("data/contacts.csv").drop(id - 1).take(1) if id.is_a?(Integer) && id > 0 
      record.nil? || record.empty? ? nil : record[0]
    end

    # Returns an array of contacts who match the given term.
    def search(term=nil)
      matches = []
      return matches if term.nil? || term.empty?
      id = 1
      CSV.foreach("data/contacts.csv") do |record|
        if Regexp.new(Regexp.quote(term), 'i').match(record.join(' '))
          record << id
          matches << record
        end
        id += 1
      end
      matches
    end

    # Get the postgres connection object
    def connection
      PG.connect(dbname: 'contacts')
    end
  end
end
