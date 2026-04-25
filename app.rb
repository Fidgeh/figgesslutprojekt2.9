require 'debug'
require "awesome_print"
require_relative 'models/exercises'
require_relative 'models/program'
require_relative 'models/users'

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
        @current_user = User.find(session[:user_id])
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

      user = User.find_user(request_username)
      
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
      @users = User.all

      erb(:"users/index")
    end

    get '/users/new' do
        erb(:"users/new")
    end

    post '/users' do
      username = params[:username]
      password = params[:password]
  
      password_hashed = BCrypt::Password.create(password)

      User.create(username, password_hashed)
      redirect "/login" 
      
    end
    
    
    get '/' do
        erb(:"exercises/index")
    end

    get '/exercises' do
      @exercises = Exercises.all
      
      erb(:"exercises/index")
    end

    post '/exercises/:id/delete' do |id|
      Exercises.delete(id)
      redirect("/exercises")
    end

    post '/program/:id/delete' do |id|
      Program_exercises.delete(id)
      Program.delete(id)
      redirect("/programs")
    end
    
    get '/exercises/new' do
      if is_admin?
        erb(:"exercises/new")
      else
        erb(:"access_denied")
      end
    end

    get '/programs/new' do
      @all_exercises = Exercises.all
      if is_admin?
        erb(:"programs/new")
      else
        erb(:"access_denied")
      end
    end

    post '/programs' do
      name = params[:program_name]
      description = params[:program_description]
      exercise_ids = params[:exercise_ids]

      new_program_id = Program.create(name, description)

      if exercise_ids
        exercise_ids.each do |ex_id|
          Program_exercises.create(new_program_id, ex_id)
        end
      end

      redirect("/programs")
    end
    
    get '/exercises/:id/edit' do |id|
      @exercise_info = Exercises.find(id)
      if is_admin?
        erb(:"exercises/edit")
      else
        erb(:"access_denied")
      end
    end

    get '/program/:id/edit' do |id|
      id = params[:id]

      @program = Program.find(id)

      @all_exercises = Exercises.all

      @current_exercise_ids = Program_exercises.find(id)

      erb(:"programs/edit")
    end

    post '/program/:id/update/?' do |id|
      id = params[:id]
      new_name = params[:program_name]
      new_desc = params[:program_description]
      selected_exercises = params[:exercise_ids]

      Program.update(id, new_name, new_desc)
      Program_exercises.delete(id)

      if selected_exercises
        selected_exercises.each do |ex_id|
          Program_exercises.create(id, ex_id)
        end
      end

      redirect("/programs")
    end
    
    
    post '/exercises/:id/update' do |id|

      e_name = params[:exercise_name]
      e_description = params[:exercise_description]
      e_primary = params[:exercise_primary]
      e_secondary = params[:exercise_secondary]

      Exercises.update(id, e_name, e_description, e_primary, e_secondary)

      redirect("/exercises")
    end

    post '/exercises' do
      p params

      t_name = params[:exercise_name]
      t_primary = params[:primary_muscle]
      t_secondary = params[:secondary_muscle]
      t_description = params[:exercise_description]
      t_img = params[:exercise_img]

      Exercises.create(t_name, t_description, t_primary, t_secondary, t_img)
      redirect('/exercises')
    end

    get '/programs' do
      @programs = Program.all
      erb(:"programs/index")
    end

    get '/programs/:id' do |id|
      @prog = Program.find(id)

      @program_exercises = Program_exercises.for_program(id)


      erb(:"programs/show")
    end

    get '/exercises/:id' do |id|
      @exercises = Exercises.find(id)
      erb(:"exercises/show")
    end


end
