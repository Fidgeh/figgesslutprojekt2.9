require 'sqlite3'

class Seeder

  def self.seed!
    p "doit"
  end

  def self.create_tables
    db.execute('CREATE TABLE excercises (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category_id INTEGER, 
                description TEXT,
                img IMG)')
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS excercises')
  end

  def self.populate_tables
    db.execute('INSERT INTO excercises (name, description, img) VALUES ("Barbell Bench Press", "Chest", "")')
    db.execute('INSERT INTO excercises (name, description, img) VALUES ("Incline Dumbbell Bench Press", "Upper Chest", "")')
    db.execute('INSERT INTO excercises (name, description, img) VALUES ("Cable Lat PUll Down", "Lats", "")')
  end

end
