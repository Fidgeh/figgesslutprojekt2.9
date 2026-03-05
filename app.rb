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

    post '/exercises/:id/delete' do |id|
      db.execute("DELETE FROM exercises WHERE id=?", id).first
      redirect("/exercises")
    end

    get '/exercises/:id' do |id|
      @exercises = db.execute('SELECT * FROM exercises WHERE id=?', id).first
      p @exercises
      erb(:"exercises/show")
    end

    get '/exercises/:id/edit' do |id|
      @exercise_info = db.execute("SELECT * FROM exercises WHERE id = ?", id).first
      p @exercise_info
      erb(:"exercises/edit")
    end

    post '/exercises/:id/update' do |id|

      e_name = params["exercise_name"]
      e_description = params["exercise_description"]
      e_primary = params["exercise_primary"]
      e_secondary = params["exercise_secondary"]

      db.execute("UPDATE exercises SET name =?, description=?, primary_group=?, secondary_group=? WHERE id =?", [e_name, e_description, e_primary, e_secondary, id])

      redirect("/exercises")
    end



end
