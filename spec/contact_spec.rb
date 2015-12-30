require 'contact'

describe Contact do
  context 'class methods' do

    describe '.all'do
      it 'returns a formatted list of all contacts' do
        expect(Contact.all).to eq([['Khurram Virani', 'kvirani@lighthouselabs.ca'], ['Don Burks', 'don@lighthouselabs.ca']])
      end
    end 

    describe '.create'do
      before(:each) do
        @name = 'Dan'
        @email = 'daniel@capitolhill.ca'
      end

      it 'responds with OK' do
        response = Contact.create(@name, @email)
        expect(response.result_status).to eq(PG::Constants::PGRES_COMMAND_OK)
      end

      it 'adds a new contact to the database' do
        results = Contact.connection.exec('SELECT count(*) FROM contacts');
        expect(results.values[0][0].to_i).to eq(2)

        contact = Contact.create(@name, @email)

        results = Contact.connection.exec('SELECT count(*) FROM contacts');
        expect(results.values[0][0].to_i).to eq(3)
      end
    end 

    describe '.find'do
      # This is a bit brittle in that it assumes the IDs will start at 1
      it 'finds the contact with the given id' do
        record = Contact.find(1) 
        expect(record.id).to eq("1")
        expect(record.name).to eq("Khurram Virani")
        expect(record.email).to eq("kvirani@lighthouselabs.ca")
        record = Contact.find(2) 
        expect(record.id).to eq("2")
        expect(record.name).to eq("Don Burks")
        expect(record.email).to eq("don@lighthouselabs.ca")
      end 

      it "doesn't barf if the given id is out of range" do
        record = Contact.find(0) 
        expect(record).to eq(nil)
        record = Contact.find(3) 
        expect(record).to eq(nil)
        record = Contact.find('junk') 
        expect(record).to eq(nil)
      end
    end 

    describe '.search'do
      it 'finds the contacts that match the search term provided' do
        records = Contact.search('khurram') 
        expect(records.count).to eq(1)
        expect(records[0][0]).to eq("1")
        expect(records[0][1]).to eq("Khurram Virani")
        expect(records[0][2]).to eq("kvirani@lighthouselabs.ca")
        records = Contact.search('kvirani') 
        expect(records.count).to eq(1)
        expect(records[0][0]).to eq("1")
        expect(records[0][1]).to eq("Khurram Virani")
        expect(records[0][2]).to eq("kvirani@lighthouselabs.ca")
        records = Contact.search('don') 
        expect(records.count).to eq(1)
        expect(records[0][0]).to eq("2")
        expect(records[0][1]).to eq("Don Burks")
        expect(records[0][2]).to eq("don@lighthouselabs.ca")
        records = Contact.search('LIGHTHOUSE') 
        expect(records.count).to eq(2)
        expect(records[0][0]).to eq("1")
        expect(records[0][1]).to eq("Khurram Virani")
        expect(records[0][2]).to eq("kvirani@lighthouselabs.ca")
        expect(records[1][0]).to eq("2")
        expect(records[1][1]).to eq("Don Burks")
        expect(records[1][2]).to eq("don@lighthouselabs.ca")
      end 

      it "doesn't barf if the search term doesn't match" do
        records = Contact.search('daniel') 
        expect(records.count).to eq(0)
        records = Contact.search('')
        expect(records.count).to eq(0)
        records = Contact.search('    ')
        expect(records.count).to eq(0)
        records = Contact.search
        expect(records.count).to eq(0)
      end 
    end

    describe '.connection' do
      it 'returns a postgres connect object' do
        conn = Contact.connection 
        expect(conn).to be_a(PG::Connection)
      end
    end
  end

  context 'instance methods' do
    before(:each) do
      @contact = Contact.new('Dan', 'daniel@capitolhill.ca')
    end

    describe '#save' do
      it 'inserts new data into the database' do
        expect(@contact.class.connection).to receive(:exec_params).
          with("INSERT INTO contacts (name, email) VALUES ($1, $2)", ['Dan', 'daniel@capitolhill.ca']).once
        @contact.save
      end

      it 'updates existing data in the database' do
        @contact.save
        results = Contact.connection.exec('SELECT count(*) FROM contacts');
        expect(results.values[0][0].to_i).to eq(3)

        contact = Contact.find(3)
        expect(contact.id).to eq('3')
        expect(contact.name).to eq('Dan')
        expect(contact.email).to eq('daniel@capitolhill.ca')

        contact.name = 'Daniel Bidulock'
        contact.email = 'daniel@rockyvalley.ca'
        contact.save

        results = Contact.connection.exec('SELECT count(*) FROM contacts');
        expect(results.values[0][0].to_i).to eq(3)

        contact = Contact.find(3)
        expect(contact.id).to eq('3')
        expect(contact.name).to eq('Daniel Bidulock')
        expect(contact.email).to eq('daniel@rockyvalley.ca')
      end
    end
  end
end
