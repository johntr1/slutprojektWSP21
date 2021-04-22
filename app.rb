require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:register)
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if password = password_confirm
        pw_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.execute("INSERT INTO users (username,pw_digest) VALUES (?,?)",username,pw_digest)
        redirect('/showlogin')
    else
        error_message = "Lösenorden stämmer ej! Vänligen försök igen."
        session[:error_message] = error_message
        session[:redirect] = "/"
        redirect('/error')
    end
end

get('/recipes') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE user_id = ?", id)
    slim(:"recipes/index", locals:{recipes:result})
end

get('/recipes/new') do
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM categories")
    slim(:"recipes/new", locals:{categories:result})
end

post('/recipes/create') do
    categories = params[:categories]
    title = params[:title]
    recipe_id = params[:recipe_id]
    user_id = session[:id].to_i
    content = params[:content]
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    db.execute("INSERT INTO recipes (content, title, user_id) VALUES (?,?,?)", content, title, user_id)
    result = db.execute("SELECT * FROM recipes WHERE content = ?",content).first
    recipe_id = result["recipe_id"] 
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories)
    redirect('/recipes')
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pw_digest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:username] = username
      redirect('/recipes')
    else
      em = "Du har skrivit fel lösenord! Vänligen försök igen."
      session[:error_message] = error_message
      session[:redirect] = "/showlogin"
      redirect("/error")
    end
end

get('/recipes/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE recipe_id = ? ", id).first
    creator_id = result["user_id"]
    creator = db.execute("SELECT * from users WHERE id = ?", creator_id).first
    category = db.execute("SELECT * FROM recipes_categories_relation WHERE recipe_id = ?", id).first
    category_id = category["category_id"]
    categories = db.execute("SELECT * FROM categories WHERE id = ?", category_id).first

    slim(:"recipes/show", locals:{result:result, creator:creator, categories:categories})
end

    





