require_relative 'model/model.rb'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

enable :sessions
include Model

t = Time.now 
i = 0
# Displays Register Page
#
get('/') do
    slim(:register)
end

#Creates a new user if the length of the username and password is larger than 3 while password_confirm is equal to password.
#Redirects to '/error' if not met with the conditions. Otherwise redirects to '/showlogin'
#
# @param [String] username, The username that the user input
# @param [String] password, The password that the user input
# @param [String] password_confirm, The confirmation that the password the user input before is correct
#
# @see Model#create_user
post('/users/new') do

    if validate_username_length(params) == false
        session[:em] = "Ditt användarnamn är för kort. Vänligen försök igen!"
        session[:re] = "/"
        redirect('/error')
    end

    if validate_password_length(params) == true
        session[:em] = "Ditt lösenord är för kort. Vänligen försök igen!"
        session[:re] = "/"
        redirect('/error')
    elsif validate_password_length(params) == false
        session[:em] = "Lösenorden matchade inte. Vänligen försök igen!"
        session[:re] = "/"
        redirect('/error')
    end

    if create_user(params) == false
        session[:em] = "Lösenorden stämmer ej! Vänligen försök igen."
        session[:re] = "/"
        redirect('/error')
    else 
        register = create_user(params)
        redirect('/showlogin')
    end
end

#Displays created recipes, bookmarked recipes and options to update created recipes. 
#The page can only be accessed if logged in.
#
# @param [Integer] :id, The users ID that has been saved in a session when logged in
# @see Model#get_all_user_recipes
# @see Model#get_all_user_liked_recipes
get('/recipes') do
    user_id = get_user_id()
        if user_id == 0
            session[:em] = "Du är tyvärr inte inloggad. Vänligen skapa ett konto eller logga in!"
            session[:re] = "/"
            redirect('/error')
        else
            result = get_all_user_recipes(params, user_id)
            liked_recipes = get_all_user_liked_recipes(params)
        end    
    slim(:"recipes/index", locals:{recipes:result, liked_recipes:liked_recipes})
end

#Displays a create form for recipes
#
# @see Model#get_all_categories
get('/recipes/new') do
    result = get_all_categories(params)
    slim(:"recipes/new", locals:{categories:result})
end

#Creates a new recipe and redirects to '/recipes'
#
# @param [Integer] categories1, The ID of the first category
# @param [Integer] categories2, The ID of the second category
# @param [Integer] categories3, The ID of the third category
# @param [String] title, The title of the new recipe
# @param [String] recipe_id, The ID of the new recipe
# @param [Integer] :id, The users ID that has been saved in a session when logged in
# @param [String] content, The instructions in the recipe 
# @see Model#create_recipe
post('/recipes/create') do
    create_recipe = create_recipe(params)
    redirect('/recipes')
end

#Displays an edit form for the recipe
#
# @param [Integer] :id, The ID of the recipe
# @see Model#get_all_categories
# @see Model#get_recipe
get('/recipes/:id/edit') do
    result = get_recipe(params)
    result2 = get_all_categories(params)
    slim(:"recipes/edit", locals:{recipes:result, categories:result2})
end

#Displays all recipes created by user with the options to delete or update
#
# param[Integer] :id, The users ID that has been saved in a session when logged in
# @see Model#get_all_user_recipes
get('/recipes/edit') do
    result = get_all_user_recipes(params, get_user_id())
    slim(:"recipes/show_edit", locals:{recipes:result})
end

#Updates an existing recipe and redirects to '/recipes/edit'
#
# @param [Integer] :id, The ID of the recipe
# @param [Integer] categories1, The ID of the first new category
# @param [Integer] categories2, The ID of the second new category
# @param [Integer] categories3, The ID of the third new category
# @param [String] title, The new title of the recipe
# @param [String] title, The new instructions in the recipe
# @see Model#update_recipe
post('/recipes/:id/update') do
    updated_recipe = update_recipe(params)
    redirect("/recipes/edit")
end

#Displays a login form
#
get('/showlogin') do
    slim(:login)
end

#Attempts to login and updates the session. Stops user from logging in with a cooldown-timer if wrong password is written more than 5 times. 
#
# @param [String] username, The username
# @param [String] password, The password
# @see Model#get_user
# @see Model#login
post('/login') do
    password = params[:password]
    db = SQLite3::Database.new('db/matreceptsida.db')
    if get_user(params) == nil
        session[:em] = "Kontot existerar inte. Vänligen registrera ett konto"
        session[:re] = "/"
        redirect("/error")
    end


    if login(params, i, t) == 1
        session[:id] = get_user(params)["id"]
        i = 0 
        redirect('/recipes')
    elsif login(params, i, t) == 2
        session[:em] = "Du har skrivit fel lösenord för många gånger! Vänligen vänta en stund."
        session[:re] = "/showlogin"
        #Time.now + (x) Ändra x beroende på hur lång cooldown-time man vill ha
        session[:time] = Time.now + (10)
        t = session[:time]
        i +=1 
        redirect("/error")

    else
        session[:em] = "Du har skrivit fel lösenord! Vänligen försök igen."
        session[:re] = "/showlogin"
        i += 1
        redirect("/error")
    end
end

#Displays all recipes that are in the database
#
# see Model#get_all_recipes
# see Model#get_all_categories
get("/recipes/public") do
    recipes = get_all_recipes(params)
    categories = get_all_categories(params)
    slim(:"recipes/public_show", locals:{recipes:recipes, categories:categories})
end

#Displays a recipe in more detail
#
# @param [Integer] :id, The ID of the recipe
# see Model#get_recipe
# see Model#get_creator_recipe
# see Model#get_recipe_categories
get('/recipes/:id') do 
    result = get_recipe(params)
    creator = get_creator_recipe(params)
    categories = get_recipe_categories(params)
    slim(:"recipes/show", locals:{result:result, creator:creator, categories:categories})
end

#Bookmarks a recipe by pressing the like button and redirects to either '/recipes' or '/error'
#
# @param [Integer] :id, The ID of the recipe
# @param [Integer] :id, The ID of the user that has been saved by a session
# see Model#like_recipe_function
post('/recipes/:id/like') do
    result = like_recipe_function(params)
    if result != false 
        redirect("/recipes")
    else
        session[:em] = "Du har redan bokmarkerat detta receptet!"
        session[:re] = "/recipes"
        redirect("/error")
    end
end
#Removes a bookmark from a bookmarked recipe by pressing the dislike button and redirects to either '/recipes' or '/error'
#
# @param [Integer] :id, The ID of the recipe
# @param [Integer] :id, The ID of the user that has been saved by a session
# see Model#delete_like_recipe_function(params)
post('/recipes/:id/dislike') do
    result = delete_like_recipe_function(params)
    if result != false
        redirect("/recipes")
    else
        session[:em] = "Du har inte bokmarkerat detta receptet!"
        session[:re] = "/recipes"
        redirect("/error")
    end
end

#Deletes an existing recipe and redirects to '/recipes'
#
# @param [Integer] :id, The ID of the recipe
# @see Model#delete_recipe
post('/recipes/:id/delete') do
    delete = delete_recipe(params)
    redirect('/recipes')
end

#Displays all recipes that belong to the category ID
#
# @param [Integer] :id, The ID of the category
# see Model#select_all_recipes_in_category
# see Model#get_category
get('/category/:id') do
    recipes = select_all_recipes_in_category(params)
    category = get_category(params)
    slim(:"recipes/public_show_categories", locals:{recipes:recipes, category:category})
end

#Logs out the user and redirects to '/'
#
post('/logout') do
    session[:id] = 0
    redirect("/")
end

#Displays the error page
#
get('/error') do
    slim(:error)
end
#Gets the session of the user_id
#
def get_user_id()
    return session[:id]
end




