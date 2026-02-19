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
                img IMG)')
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS exercises')
  end

  def self.populate_tables
    db.execute('INSERT INTO exercises (name, description, img) VALUES ("Barbell Bench Press", "Chest", "")')
    db.execute('INSERT INTO exercises (name, description, img) VALUES ("Incline Dumbbell Bench Press", "Upper Chest", "")')
    db.execute('INSERT INTO exercises (name, description, img) VALUES ("Cable Lat Pull Down", "Lats", "")')
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
