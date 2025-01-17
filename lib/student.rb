require_relative "../config/environment.rb"

# Remember, you can access your database connection anywhere in this class with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql_2 = "INSERT INTO students(name, grade) VALUES(?, ?);"
      DB[:conn].execute(sql_2, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    student = self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql_1 = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql_1, self.name, self.grade, self.id)
  end
end
