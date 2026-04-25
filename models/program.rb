require_relative 'base_model'

class Program < BaseModel

  def self.all()
    sql_program = 'SELECT * FROM program'
    program = db.execute(sql_program)
    return program
  end

  def self.create(name, description)
    new_prog = 'INSERT INTO program (name, description) VALUES (?, ?)'
    db.execute(new_prog, [name, description])
    return db.last_insert_row_id
  end

  def self.find(id)
    sql_program = 'SELECT * FROM program WHERE id =?'
    program = db.execute(sql_program, id).first
    return program
  end

  def self.update(id, new_name, new_desc)
    sql = 'UPDATE program SET name =?, description=? WHERE id =?'
    db.execute(sql, [new_name, new_desc, id])
  end

  def self.delete(id)
    db.execute('DELETE FROM program WHERE id =?', id).first
  end

end