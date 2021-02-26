require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:register)
end

get('/recipes') do

    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE")


end
