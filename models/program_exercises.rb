require_relative 'base_model'

class Program_exercises < BaseModel

  def self.all()
    sql_program_exercises = 'SELECT * FROM program_exercises'
    program = db.execute(sql_program)
    return program
  end

  def self.create(new_program_id, ex_id)
    db.execute('INSERT INTO program_exercises (program_id, exercise_id) VALUES (?, ?)', [new_program_id, ex_id])
  end

  def self.find(id)
    rows = db.execute('SELECT exercise_id FROM program_exercises WHERE program_id =?', id)
    rows.map { |row| row["exercise_id"]}
  end

  def self.delete(id)
    db.execute('DELETE FROM program_exercises WHERE id =?', id).first
  end

  def self.for_program(id)
    db.execute("
      SELECT exercises.*
      FROM exercises
      JOIN program_exercises
        ON exercises.id = program_exercises.exercise_id
      WHERE program_exercises.program_id = ?
      ", id)
  end

end