require './lib/contact'
require 'active_support/inflector'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  def initialize(argv=[])
    @input = argv
  end

  def process
    case @input[0]
    when 'list'
      contacts = Contact.all
      contacts.each_with_index do |contact, index|
        puts "#{index + 1}: #{contact[0]} (#{contact[1]})"
      end
      puts '---'
      puts "#{contacts.count} records total"
    when 'new'
      # kernel#gets only works if argv is empty
      puts 'Name:'
      name = STDIN.gets.chomp
      puts 'Email:'
      email = STDIN.gets.chomp
      Contact.create(name, email)
    when 'show'
      id = @input[1].to_i
      record = Contact.find(id)
      puts record.nil? ? "That contact doesn't exist" : "#{record[0]}: #{record[1]} (#{record[2]})"
    when 'search'
      # This should be DRYed out
      contacts = Contact.search(@input[1])
      contacts.each do |contact|
        puts "#{contact[0]}: #{contact[1]} (#{contact[2]})"
      end
      puts '---'
      puts "#{contacts.count} #{"record".pluralize(contacts.count)} total"
    when nil 
      puts "Here is a list of available commands:\n"\
           "  new    - Create a new contact\n"\
           "  list   - List all contacts\n"\
           "  show   - Show a contact\n"\
           "  search - Search contacts\n"\
           "  update - Update a contact\n"
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  ContactList.new(ARGV).process
end
