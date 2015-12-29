require 'pg'
require 'csv'

namespace :test do

  desc 'setup test database'
  task :create_db do
    conn = PG.connect(dbname: 'postgres')
    conn.exec('DROP DATABASE IF EXISTS test_contacts')
    conn.exec('CREATE DATABASE test_contacts')
    conn = PG.connect(dbname: 'test_contacts')
    conn.exec('CREATE TABLE contacts (id serial NOT NULL PRIMARY KEY, name varchar(40) NOT NULL, email varchar(40) NOT NULL)')
  end
end

desc 'setup database'
task :create_db do
  conn = PG.connect(dbname: 'postgres')
  conn.exec('DROP DATABASE IF EXISTS contacts')
  conn.exec('CREATE DATABASE contacts')
  conn = PG.connect(dbname: 'contacts')
  conn.exec('CREATE TABLE contacts (id serial NOT NULL PRIMARY KEY, name varchar(40) NOT NULL, email varchar(40) NOT NULL)')
  CSV.foreach("data/contacts.csv") do |record|
    conn.exec_params('INSERT INTO contacts (name, email) VALUES ($1, $2)', record)
  end
end
