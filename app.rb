require 'debug'
require "awesome_print"

class App < Sinatra::Base

    setup_development_features(self)

    # Funktion för att prata med databasen
    # Exempel på användning: db.execute('SELECT * FROM fruits')
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    # Routen /
    get '/' do
        erb(:"exercises/index")
    end

    get '/exercises' do
      @exercises = db.execute('SELECT * FROM exercises')
      
      erb(:"exercises/index")
    end

    get '/exercises/:id' do |id|
      @exercises = db.execute('SELECT * FROM exercises WHERE id=?', id).first
      
      erb(:"exercises/show")
    end

end
