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

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end

    before do
      if session[:user_id]
        @current_user = db.execute("SELECT * FROM users WHERE id=?", session[:user_id]).first
        ap @current_user
      end
    end


    # Routen /
    get '/admin' do
      if session[:user_id]
        erb(:"admin/index")
      else
        ap "/admin : Access denied."
        status 401
        redirect '/access_denied'
      end
    end

    get '/access_denied' do 
      erb(:login)
    end

    post '/login' do 
      request_username = params[:username]
      request_plain_password = params[:password]

      user = db.execute("SELECT *
              FROM users
              WHERE username = ?",
              request_username).first
      
      unless user
        ap "/login : Invalid username."
        status 401
        redirect '/access_denied'
      end

      db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s

      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

      if bcrypt_db_password == request_plain_password
        ap "/login : Logged in -> redirecting to admin"
        session[:user_id] = db_id
        redirect '/admin'
      else
        ap "/login : Invalid password."
        status 401
        redirect '/access_denied'
      end
    end

    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/'
    end

    get '/users/new' do
      erb(:"users/new")
    end
    
    
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
