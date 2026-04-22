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

    helpers do
      def is_admin?
        # Returnerar true om sessionen har ett user_id, annars false
        !!session[:user_id]
      end

      def require_admin
        unless is_admin?
          ap "Access denied: User not logged in."
          halt 401, redirect('/access_denied')
        end
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
      erb(:access_denied)
    end

    get '/login' do
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
      redirect '/exercises'
    end

    get '/users/index' do
      @users = db.execute("SELECT * FROM users")

      erb(:"users/index")
    end

    get '/users/new' do
      erb(:"users/new")
    end

    post '/users' do
      username = params[:username]
      password = params[:password]
  
      password_hashed = BCrypt::Password.create(password)
  
      db = SQLite3::Database.new(DB_PATH)

      db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password_hashed])
      redirect "/login" 
      
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

    post '/program/:id/delete' do |id|
      db.execute("DELETE FROM program_exercises WHERE program_id = ?", id)
      db.execute("DELETE FROM program WHERE id=?", id)
      redirect("/exercises/programs")
    end
    
    get '/exercises/new' do
      erb(:"exercises/new")
    end

    
    get '/exercises/:id/edit' do |id|
      @exercise_info = db.execute("SELECT * FROM exercises WHERE id = ?", id).first
      p @exercise_info
      if is_admin?
        erb(:"exercises/edit")
      else
        erb(:"access_denied")
      end
    end

    get '/program/:id/edit' do |id|
      id = params[:id]
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true

      @program = db.execute("SELECT * FROM program WHERE id = ?", id).first

      @all_exercises = db.execute("SELECT * FROM exercises")

      existing_relations = db.execute("SELECT exercise_id FROM program_exercises WHERE program_id = ?", id)
      @current_exercise_ids = existing_relations.map { |row| row["exercise_id"]}

      erb(:"programs/edit")
    end

    post '/program/:id/update/?' do |id|
      id = params[:id]
      new_name = params[:program_name]
      new_desc = params[:program_description]
      selected_exercises = params[:exercise_ids]

      db = SQLite3::Database.new(DB_PATH)

      db.execute("UPDATE program SET name=?, description=? WHERE id=?", [new_name, new_desc, id])
      db.execute("DELETE FROM program_exercises WHERE program_id=?", [id])

      if selected_exercises
        selected_exercises.each do |ex_id|
          db.execute("INSERT INTO program_exercises (program_id, exercise_id) VALUES(?, ?)", [id, ex_id])
        end
      end

      redirect("/programs")
    end
    
    
    post '/exercises/:id/update' do |id|

      e_name = params["exercise_name"]
      e_description = params["exercise_description"]
      e_primary = params["exercise_primary"]
      e_secondary = params["exercise_secondary"]

      db.execute("UPDATE exercises SET name =?, description=?, primary_group=?, secondary_group=? WHERE id =?", [e_name, e_description, e_primary, e_secondary, id])

      redirect("/exercises")
    end

    post '/exercises' do
      p params

      t_name = params[:exercise_name]
      t_primary = params[:primary_muscle]
      t_secondary = params[:secondary_muscle]
      t_description = params[:exercise_description]
      t_img = params[:exercise_img]

      db.execute("INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES(?, ?, ?, ?, ?)", [t_name, t_description, t_primary, t_secondary, t_img])
      redirect('/exercises')
    end

    get '/programs' do
      @programs = db.execute('SELECT * FROM program')
      erb(:"programs/index")

    end

    get '/programs/:id' do |id|
      @prog = db.execute('SELECT * FROM program WHERE id=?', id).first

      @program_exercises = db.execute("
      SELECT exercises.*
      FROM exercises
      JOIN program_exercises
        ON exercises.id = program_exercises.exercise_id
      WHERE program_exercises.program_id = ?
      ", id)


      erb(:"programs/show")
    end

    get '/exercises/:id' do |id|
      @exercises = db.execute('SELECT * FROM exercises WHERE id=?', id).first
      p @exercises
      erb(:"exercises/show")
    end


end
