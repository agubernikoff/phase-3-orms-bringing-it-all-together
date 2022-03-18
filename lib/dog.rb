require "pry"
class Dog

    attr_accessor :name, :breed, :id

    def initialize args
        args.each do |key, value|
            self.send("#{key}=", args[key])
        end
    end

    def self.create_table
        sql= <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
        SQL
        DB[:conn].execute(sql)
    end
    
    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql= <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?,?)
        SQL

        DB[:conn].execute(sql,self.name,self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
    end

    def self.create(args)
        new_dog=Dog.new(args)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new({id:row[0],name:row[1],breed:row[2]})
    end

    def self.all
        sql= <<-SQL
        SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            Dog.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql= <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL

        a=DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql= <<-SQL
        SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL

        a=DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end
end
