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
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS exercises')
  end

  def self.populate_tables
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Barbell Bench Press", "Press weight", "Chest", "Tricep", "/img/Barbell-Bench-Press.gif")')
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Incline Dumbbell Bench Press", "Press weight but inclined", "Upper Chest", "tricep", "/img/Incline_Dumbbell_Bench_Press.gif")')
    db.execute('INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES ("Cable Lat Pulldown", "Pull weight", "Lats", "Bicep", "/img/Lat_Pulldown.gif")')
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
