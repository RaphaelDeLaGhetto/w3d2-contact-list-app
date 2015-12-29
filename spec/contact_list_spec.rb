require_relative '../contact_list'
require './lib/contact'

describe ContactList do
  describe '#process' do

    before(:each) do
      data = ['Khurram Virani,kvirani@lighthouselabs.ca', 'Don Burks,don@lighthouselabs.ca']
      allow(CSV).to receive(:read).and_return(CSV.parse(data[0]) << CSV.parse(data[1])[0])
    end

    context 'program is executed without arguments' do
      it "displays a help menu" do
        expect { ContactList.new([]).process }.to output("Here is a list of available commands:\n"\
                                                         "  new    - Create a new contact\n"\
                                                         "  list   - List all contacts\n"\
                                                         "  show   - Show a contact\n"\
                                                         "  search - Search contacts\n"\
                                                         "  update - Update a contact\n").to_stdout
      end
    end
  
    context "program is executed with 'help' argument" do
      it "outputs a list of all contacts" do
        expect { ContactList.new(['list']).process }.to output("1: Khurram Virani (kvirani@lighthouselabs.ca)\n"\
                                                               "2: Don Burks (don@lighthouselabs.ca)\n"\
                                                               "---\n"\
                                                               "2 records total\n").to_stdout
      end
    end

    context "program is executed with 'new' argument" do
      before(:each) do
        # New contact details
        @name = 'Dan'
        @email = 'daniel@capitolhill.ca'

        # Stage the test
        @contact_list = ContactList.new(['new'])

        # Commandline input 
        call = -1 
        allow(STDIN).to receive_message_chain(:gets) do 
          [@name, @email][call += 1]
        end
        @response = @contact_list.process
      end

      it "prompts agent for name and email information" do
        expect(STDOUT).to receive(:puts).with('Name:')
        expect(STDOUT).to receive(:puts).with('Email:')

        contact = ContactList.new(['new'])

        allow(STDIN).to receive(:gets) { @name }
        allow(STDIN).to receive(:gets) { @email }
        contact.process
      end

      it "adds a new contact to the database" do
        results = Contact.connection.exec('SELECT count(*) FROM contacts');
        expect(results.values[0][0].to_i).to eq(3)
      end

      it "responds with OK" do
        expect(@response.result_status).to eq(PG::Constants::PGRES_COMMAND_OK)
      end
    end

    context "program is executed with 'find' argument" do
      it 'outputs the information belonging to the contact with the corresponding id' do
        expect { ContactList.new(['show', '1']).process }.to output("1: Khurram Virani (kvirani@lighthouselabs.ca)\n").to_stdout
        expect { ContactList.new(['show', '2']).process }.to output("2: Don Burks (don@lighthouselabs.ca)\n").to_stdout
      end

      it "doesn't barf if the given id is out of range" do
        expect { ContactList.new(['show', '-1']).process }.to output("That contact doesn't exist\n").to_stdout
        expect { ContactList.new(['show', '0']).process }.to output("That contact doesn't exist\n").to_stdout
        expect { ContactList.new(['show', '3']).process }.to output("That contact doesn't exist\n").to_stdout
        expect { ContactList.new(['show', 'junk']).process }.to output("That contact doesn't exist\n").to_stdout
      end
    end

    context "program is executed with 'search' argument" do
      it 'outputs the information belonging to the contacts whose details match the search term' do
        expect { ContactList.new(['search', 'khurram']).process }.to output("1: Khurram Virani (kvirani@lighthouselabs.ca)\n"\
                                                                            "---\n"\
                                                                            "1 record total\n").to_stdout
        expect { ContactList.new(['search', 'don']).process }.to output("2: Don Burks (don@lighthouselabs.ca)\n"\
                                                                        "---\n"\
                                                                        "1 record total\n").to_stdout
        expect { ContactList.new(['search', 'LIGHTHOUSE']).process }.to output("1: Khurram Virani (kvirani@lighthouselabs.ca)\n"\
                                                                               "2: Don Burks (don@lighthouselabs.ca)\n"\
                                                                               "---\n"\
                                                                               "2 records total\n").to_stdout
      end

      it "doesn't barf if nothing matches the search term" do
         expect { ContactList.new(['search', 'daniel']).process }.to output("---\n"\
                                                                            "0 records total\n").to_stdout
      end
    end
  end
end
