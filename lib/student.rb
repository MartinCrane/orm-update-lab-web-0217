require_relative "../config/environment.rb"
require 'pry'
class Student

  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
   end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table

    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL

      sqlid = <<-SQL
        SELECT last_insert_rowid()

        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute(sqlid)[0][0]
    else
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

  end

  def self.create(name, grade)
    student_object = Student.new(name, grade)
    student_object.save

  end

  def self.new_from_db(row)
    id = row[0]
    grade = row[2]
    name = row[1]
    new_student = Student.new(name, grade)
    new_student.id = id
    new_student
  end

  def self.find_by_name(stu_name)

    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    SQL

    stu_arr = DB[:conn].execute(sql,stu_name).flatten

    new_student = Student.new(stu_arr[1], stu_arr[2], stu_arr[0])
    new_student
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET NAME = ?, GRADE = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
