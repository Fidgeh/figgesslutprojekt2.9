require 'sqlite3'

class Seeder

  def self.seed!
    puts "Using db file: #{DB_PATH}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.create_tables
    db.execute('CREATE TABLE exercises (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category_id INTEGER, 
                description TEXT,
                primary_group TEXT,
                secondary_group TEXT,
                img_path TEXT)')

    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL)')
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS exercises')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.populate_tables
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Barbell Bench Press", "Press weight", "Chest", "Tricep", "/img/Barbell-Bench-Press.gif")')
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Incline Dumbbell Bench Press", "Press weight but inclined", "Upper Chest", "tricep", "/img/Incline_Dumbbell_Bench_Press.gif")')
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Cable Lat Pulldown", "Pull weight", "Lats", "Bicep", "/img/Lat_Pulldown.gif")')
  
    password_hashed = BCrypt::Password.create("123")
    p "Storing hashed password (#{password_hashed}) to DB. Clear text password (123) never saved"
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["figge", password_hashed])

  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!
