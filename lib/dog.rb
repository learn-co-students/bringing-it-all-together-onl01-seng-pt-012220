class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize( id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (id, name, breed) VALUES (?, ?, ?);
      SQL

      DB[:conn].execute(sql, @id, @name, @breed)


      sql = <<-SQL
        SELECT last_insert_rowid() FROM dogs;
      SQL

      @id = DB[:conn].execute(sql)[0][0]
    end
    self
  end

  def self.create(id: nil, name:, breed:)
    self.new( id: id, name: name, breed: breed).save
  end

  def self.new_from_db(row)
    self.create(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_data = DB[:conn].execute(sql, id)[0]

    self.new_from_db(dog_data)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog_data = DB[:conn].execute(sql, name, breed)[0]

    if dog_data
      return self.new_from_db(dog_data)
    else
      return self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog_row = DB[:conn].execute(sql, name)[0]

    self.new_from_db(dog_row)
  end

  def update
    sql =<<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
