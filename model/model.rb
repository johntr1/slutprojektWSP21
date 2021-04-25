module Model
    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    # @option params [String] password_confirm The repeated password
    def create_user(params)
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        if username.length <= 3 
            session[:em] = "Ditt användarnamn är för kort. Vänligen försök igen!"
            session[:re] = "/"
            redirect('/error')
        end
    
        if password.length <= 3 and password_confirm.length == 0 
            session[:em] = "Ditt lösenord är för kort. Vänligen försök igen!"
            session[:re] = "/"
            redirect('/error')
        elsif password_confirm.length <= 3 or password != password_confirm
            session[:em] = "Lösenorden matchade inte. Vänligen försök igen!"
            session[:re] = "/"
            redirect('/error')
        end
    
        if password_confirm == password
            db = SQLite3::Database.new('db/matreceptsida.db')
            pw_digest = BCrypt::Password.create(password)
            db.execute("INSERT INTO users (username,pw_digest) VALUES (?,?)",username,pw_digest)
            redirect('/showlogin')
        else
            session[:em] = "Lösenorden stämmer ej! Vänligen försök igen."
            session[:re] = "/"
            redirect('/error')
        end
    end
    #Attempts to retrieve all recipes created by the user
    #
    # @param [Hash] params form data
    # @option params[Integer] id The ID of the user
    # 
    # @return [Hash]
    # * :recipe_id [Integer] The name of the recipe
    # * :content [String] The instructions in the recipe
    # * :title [String] The name of the recipe
    # * :user_id [Integer] The ID of the user
    def get_all_user_recipes(params)
        user_id = session[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM recipes WHERE user_id = ?", user_id)
        return result
    end

    #Attempts to retrieve all recipes that the user has bookmarked
    #
    # @param [Integer] params form data
    # @option params[Integer] id The ID of the user
    #
    # @return [Hash]
    # * :recipe_id [Integer] The name of the recipe
    # * :content [String] The instructions in the recipe
    # * :title [String] The name of the recipe
    # * :user_id [Integer] The ID of the user
    # * :user_recipe_id [Integer] The ID of the connection between user and recipe
    def get_all_user_liked_recipes(params)
        id = session[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        liked_recipes = db.execute("SELECT * FROM users_recipes_likes_relation INNER JOIN recipes ON users_recipes_likes_relation.recipe_id = recipes.recipe_id WHERE users_recipes_likes_relation.user_id = ?", id)
        return liked_recipes
    end

    #Attempts to get all categories from the categories table
    #
    # @return [Hash]
    # * :id [Integer] The ID of the category
    # * :name [String] The name of the category
    def get_all_categories(params)
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM categories")
        return result
    end
    
    #Attempts to get all recipes from the recipe table
    #
    # @return [Hash]
    # * :recipe_id [Integer] The name of the recipe
    # * :content [String] The instructions in the recipe
    # * :title [String] The name of the recipe
    # * :user_id [Integer] The ID of the user
    def get_all_recipes(params)
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM recipes")
        return result
    end

    #Attempts to create a new recipe by inserting a new row in the recipe table, and three new rows in the recipes_categories_relation table
    #
    # @param [Hash] params form data
    # @option params [Integer] categories1 The ID of the first category
    # @option params [Integer] categories2 The ID of the second category
    # @option params [Integer] categories3 The ID of the third category
    # @option params [String] title, The title of the new recipe
    # @option params [Integer] recipe_id The ID of the new recipe
    # @option params [Integer] id, The ID of the user
    # @option params [String] content, The instructions in the new recipe
    def create_recipe(params)
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
    end

    #Attempts to get one single recipe from the database
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    #
    # @return [Hash]
    # * :recipe_id [Integer] The ID of the recipe
    # * :content [String] The instructions of the recipe
    # * :title [String] The title of the recipe
    # * :user_id [Integer] The ID of the user
    def get_recipe(params)
        id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM recipes WHERE recipe_id = ?", id).first
        return result
    end
    
    #Attempts to get the creators row of data by using the recipe's ID
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    #
    # @return [Hash]
    # * :id [Integer] The ID of the user
    # * :username [String] The name of the user
    # * :pw_digest [String] The encrypted password
    def get_creator_recipe(params)
        id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = get_recipe(params)
        creator_id = result["user_id"]
        creator = db.execute("SELECT * from users WHERE id = ?", creator_id).first
        return creator
    end
    
    #Attempts to get the three rows of categories from one recipe
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    # 
    # @return [Hash]
    # * :name [String] The name of the category
    # * :id [Integer] The ID of the category
    def get_recipe_categories(params)
        id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        category_id = db.execute("SELECT category_id FROM recipes_categories_relation WHERE recipe_id = ?", id)
        category_id1 = category_id[0]["category_id"]
        category_id2 = category_id[1]["category_id"]
        category_id3 = category_id[2]["category_id"]
        categories = db.execute("SELECT * FROM categories WHERE id = ? or id = ? or id = ?", category_id1, category_id2, category_id3 )
        return categories
    end

    #Attempts to update a row in the recipe table
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    # @option params [Integer] categories1 The new ID of the first category
    # @option params [Integer] categories2 The new ID of the second category
    # @option params [Integer] categories3 The new ID of the third category
    # @option params [String] content, The new instructions in the new recipe
    # @option params [String] title, The new title of the recipe
    def update_recipe(params)
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
    end

    #Attempts to bookmark a recipe when the Like button is pressed
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    #
    # @return [Boolean] whether an error has occurred
    def like_recipe_function(params)
        recipe_id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        user_id = session[:id].to_i
        db.results_as_hash = true
        check = db.execute("SELECT * FROM users_recipes_likes_relation WHERE user_id = ? and recipe_id = ?", user_id, recipe_id).first
        if check == nil 
            result = db.execute("INSERT INTO users_recipes_likes_relation (recipe_id, user_id) VALUES (?, ?)", recipe_id, user_id)
            return result
        else
            return false
        end
    end
    #Attempts to delete the bookmark from a currently bookmarked recipe
    #
    # @param [Integer] :id The ID of the user saved by a session
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    #
    # @return [Boolean] whether an error has occurred
    def delete_like_recipe_function(params)
        recipe_id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        user_id = session[:id].to_i
        db.results_as_hash = true
        check = db.execute("SELECT * FROM users_recipes_likes_relation WHERE user_id = ? and recipe_id = ?", user_id, recipe_id).first
        if check != nil 
            result = db.execute("DELETE FROM users_recipes_likes_relation WHERE recipe_id = ? and user_id = ?", recipe_id, user_id)
            return result
        else
            return false
        end
    end

    #Attempts to delete a row frrom the recipes table
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the recipe
    def delete_recipe(params)
        recipe_id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.execute("DELETE FROM recipes WHERE recipe_id = ?", recipe_id)
    end

    #Attempts to select all recipes that belong to a specific category
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the category
    #
    # @return [Hash]
    # * :recipe_id [Integer] The ID of the recipe
    # * :category_id [Integer] The ID of the category
    # * :content [String] The instructions in the recipe
    # * :title [String] The name of the recipe
    # * :user_id [Integer] The users ID
    def select_all_recipes_in_category(params)
        category_id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        recipes = db.execute("SELECT * FROM recipes_categories_relation INNER JOIN recipes ON recipes_categories_relation.recipe_id = recipes.recipe_id WHERE recipes_categories_relation.category_id = ?", category_id)
        return recipes
    end
    
    #Attempts to get one row from the category table
    #
    # @param [Hash] params form data
    # @option params [Integer] :id The ID of the category
    #
    # @return [Hash]
    # * :name [String] The name of the category
    # * :id [Integer] The ID of the category
    def get_category(params)
        category_id = params[:id].to_i
        db = SQLite3::Database.new('db/matreceptsida.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM categories WHERE id = ?", category_id).first
        return result
    end

end