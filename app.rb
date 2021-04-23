require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

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
    if id == 0
        redirect('/')
    else
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM recipes WHERE user_id = ?", id)
    end
    slim(:"recipes/index", locals:{recipes:result})
end

get('/recipes/new') do
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM categories")
    slim(:"recipes/new", locals:{categories:result})
end

post('/recipes/upload_image') do
    path = File.join("../public/uploaded_pictures/",params[:file][:filename])

    File.write(path,File.read(params[:file[:tempfile]]))

    redirect('/recipes/new')
end


post('/recipes/create') do
    categories1 = params[:categories1]
    categories2 = params[:categories2]
    categories3 = params[:categories3]
    title = params[:title]
    recipe_id = params[:recipe_id]
    user_id = session[:id].to_i
    content = params[:content]
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    db.execute("INSERT INTO recipes (content, title, user_id) VALUES (?,?,?)", content, title, user_id)
    result = db.execute("SELECT * FROM recipes WHERE content = ?",content).first
    recipe_id = result["recipe_id"] 
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories1)
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories2)
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories3)
    redirect('/recipes')
end

get('/recipes/:id/edit') do
    id = params[:id].to_i
    title = params[:title]
    params[:content]
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE recipe_id = ?", id).first
    result2 = db.execute("SELECT * FROM categories")
    slim(:"recipes/edit", locals:{recipes:result, categories:result2})
end

get('/recipes/edit') do
    user_id = session[:id].to_i
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE user_id = ?", user_id)
    slim(:"recipes/show_edit", locals:{recipes:result})
end

post('/recipes/:id/update') do
    recipe_id = params[:id].to_i
    categories1 = params[:categories1]
    categories2 = params[:categories2]
    categories3 = params[:categories3]
    title = params[:title]
    content = params[:content]
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.execute("UPDATE recipes SET title=?, content=? WHERE recipe_id = ?", title, content, recipe_id)
    db.execute("DELETE FROM recipes_categories_relation WHERE recipe_id = ?", recipe_id)
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories1)
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories2)
    db.execute("INSERT INTO recipes_categories_relation (recipe_id, category_id) VALUES (?, ?)", recipe_id, categories3)

   redirect("/recipes/edit")

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

get("/recipes/public") do
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    recipes = db.execute("SELECT * FROM recipes")
    slim(:"recipes/public_show", locals:{recipes:recipes})


end

get('/recipes/:id') do 
    id = params[:id].to_i
    db = SQLite3::Database.new('db/matreceptsida.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM recipes WHERE recipe_id = ? ", id).first
    creator_id = result["user_id"]
    creator = db.execute("SELECT * from users WHERE id = ?", creator_id).first
    category_id = db.execute("SELECT category_id FROM recipes_categories_relation WHERE recipe_id = ?", id)
    category_id1 = category_id[0]["category_id"]
    category_id2 = category_id[1]["category_id"]
    category_id3 = category_id[2]["category_id"]

    categories = db.execute("SELECT * FROM categories WHERE id = ? or id = ? or id = ?", category_id1, category_id2, category_id3 )

    slim(:"recipes/show", locals:{result:result, creator:creator, categories:categories})
end

post('/recipes/:id/like') do
    recipe_id = params[:id].to_i
    db = SQLite3::Database.new('db/matreceptsida.db')
    user_id = session[:id].to_i
    db.results_as_hash = true
    check = db.execute("SELECT * FROM users_recipes_likes_relation WHERE user_id = ? and recipe_id = ?", user_id, recipe_id).first
    if check == nil 
        db.execute("INSERT INTO users_recipes_likes_relation (recipe_id, user_id) VALUES (?, ?)", recipe_id, user_id)
    else
        redirect("/show_login")
    end
    redirect("/recipes")
end






