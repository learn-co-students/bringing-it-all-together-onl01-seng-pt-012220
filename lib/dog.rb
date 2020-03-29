class Dog

    attr_accessor :name, :breed, :id


    def initialize(id: nil,name:,breed:)
        @name = name
        @breed = breed
        @id = id

    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE dogs')
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name,breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:name,breed:breed)
        dog_attributes = {name: name,breed: breed}
        #binding.pry
        dog = Dog.new(dog_attributes)
        dog.save
    end
    
    def self.new_from_db(row)
       new_dog = create(name:row[1],breed:row[2])
       new_dog.id = row[0]
       new_dog
    end

    def self.find_by_id(sought_id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",sought_id)[0]
        new_dog = Dog.new(id:sought_id,name:row[1],breed:row[2])
        #binding.pry
        new_dog
    end

    def self.find_or_create_by(name:name,breed:breed)

        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql,name,breed)


        if !dog.empty?
            dog = dog[0]
            new_dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
        else
            new_dog = self.create(name:name,breed:breed)
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        new_dog = DB[:conn].execute(sql,name)
        self.new_from_db(new_dog[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end