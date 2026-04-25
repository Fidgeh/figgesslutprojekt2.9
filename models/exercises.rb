require_relative 'base_model'

class Exercises < BaseModel

  def self.all()
    sql_exercises = 'SELECT * FROM exercises'
    exercises = db.execute(sql_exercises)
    return exercises
  end

  def self.create(t_name, t_description, t_primary, t_secondary, t_img)
    new_exer = 'INSERT INTO exercises (name, description, primary_group, secondary_group, img_path) VALUES (?, ?, ?, ?, ?)'
    exer = db.execute(new_exer, [t_name, t_description, t_primary, t_secondary, t_img])

  end

  def self.find(id)
    sql_exercises = 'SELECT * FROM exercises WHERE id =?'
    exercise = db.execute(sql_exercises, id).first
    return exercise
  end

  def self.update(id, e_name, e_description, e_primary, e_secondary)
    sql = 'UPDATE exercises SET name =?, description=?, primary_group=?, secondary_group=? WHERE id =?'
    db.execute(sql, [e_name, e_description, e_primary, e_secondary, id])
  end

  def self.delete(id)
    db.execute('DELETE FROM exercises WHERE id =?', id).first
  end

end