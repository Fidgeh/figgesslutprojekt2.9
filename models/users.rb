require_relative 'base_model'

class User < BaseModel

  def self.all()
    sql_users = 'SELECT * FROM users'
    users = db.execute(sql_users)
    return users
  end

  def self.create(username, password)
    new_user = 'INSERT INTO users (username, password) VALUES (?, ?)'
    user = db.execute(new_user, [username, password])
    return user
  end

  def self.find(id)
    sql_users = 'SELECT * FROM users WHERE id =?'
    user = db.execute(sql_users, id).first
    return user
  end

  def self.find_user(username)
    user = db.execute(" SELECT *
    FROM users
    WHERE username = ?",
    username).first
    return user
  end

end