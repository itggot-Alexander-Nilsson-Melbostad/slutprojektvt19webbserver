module AppModule


    # Validates information upon creating account
    #
    # @params ["username"] params form for username
    # @params ["password"] params form for password 
    # @params ["nickname"] params form for nickname
    #
    # @return Boolean [True] if data matches requirements for information input


    def validate_info_create(params)
        if params["username"].nil? || params["password"].nil? || params["nickname"].nil? 
            return false
        else
            return true 
        end
    end 

    # Validates information upon making a review
    #
    # @params ["review_text] params form for the main content input
    # @params ["review_username] params form for username 
    # @params ["review_user_id"] params form for users identification on given review
    # @params ["review_header"] params form for main header in created review
    #
    # @return Boolean [True] if data matches requirements for information input

    def validate_info_makereview(params)
        if params["review_text"].nil? || params["review_username"].nil? || params["review_user_id"].nil? || params["review_header"].nil?
            return false
        else 
            return true
        end
    end

    # Validates product upon adding a product to the cart
    #
    # @params  session[:product_id] the product's id located in database 
    #
    # @return Boolean [True] if the paroduct id exists in database

    def validate_info_add_to_cart(params)
        if session[:product_id].nil?
            return false
        else 
            return true
        end
    end

    # Validates information upon changing username
    #
    # @params ["change_username"] The information given in form of changing username 
    #
    # @return Boolean [True] if the username input is an actual username and not for example nil

  

    def validate_info_change_username(params)
        if params["change_username"].nil?
            return false
        else 
            return true
        end
    end 

    # Validates information upon changing password
    #
    # @params ["change_password"] The information given in form of changing username 
    #
    # @return Boolean [True] if the password input is an legitimate password and not for example nil


    def validate_info_change_password(params)
        if params["change_password"].nil?
            return false
        else 
            return true
        end
    end 

    # Validates information upon logging in
    #
    # @params ["username"] params form for username
    #
    # @return Boolean [True] if data matches requirements for information input (>10 <2 != nil)
    

    def validate_info_login(params)
        if params["username"].nil? || params["username"].length > 10 || params["username"].length < 2 
            return false
        else 
            return true
        end
    end 
       
    # Calling upon database file from module SQLlite3
    #
    # @params [""] params form for username
    #
    # @return Boolean [True] if data matches requirements for information input (>10 <2 != nil)

    def database()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        db
    end

    # logging in 
    #
    # @params ["username"] params form for username     
    # @params ["password"] params form for password 
    # @params ["user_id"] params form for users identification on given login
    # @params ["nickname"] params form for nickname on logging in
    #
    # @return Boolean [True] if data matches requirements for information input

    def login(params)
        if validate_info_login(params)
            db = SQLite3::Database.new("db/db.db")
            db.results_as_hash = true
            result = db.execute("SELECT username, password, user_id, authority, nickname FROM users WHERE username = ?", params["username"])
            if BCrypt::Password.new(result[0]["password"]) == params["password"]
                session[:user] = params["username"]
                session[:user_id] = result[0]["user_id"]
                session[:nickname] = params["nickname"]
                redirect("/")
            else
                redirect("/loginfailed")
            end
            slim(:index, locals:{
                index: result
            })
        end
    end

    # Create an account 
    #
    # @params ["username"] params form for username     
    # @params ["password1"] params form for password 
    # @params ["nickname"] params form for nickname on logging in
    #
    # @return Boolean [True] input to database requirements are matched

    def create(params)
        if validate_info_create(params)
            db = SQLite3::Database.new("db/db.db")
            db.results_as_hash = true   
            new_name = params["username"] 
            new_password = params["password1"]
            new_nickname = params["nickname"]
            new_password_hash = BCrypt::Password.create(new_password)
            db.execute("INSERT INTO users (username, password, authority, nickname) VALUES (?,?,?,?)", new_name, new_password_hash, 1, new_nickname)
            redirect("/")
        else
            redirect("/loginfailed")
        end
    end

    # Clearing users cart
    #
    # @session ["user_id"] Identification linked to currently logged in user     
    #
    # @return [input] to database requirements are matched

    def clearcart(user_id)
        db = database()
        db.execute("DELETE FROM cart WHERE cart.user_id = ?", user_id)
        redirect("/webshop")
    end

    # Obtaining information about the reviews to print them on the app
    #
    # @session ["user_id"] Identification linked to currently logged in user     
    #
    # @return [input] to database requirements are matched

    def review()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        showreview = db.execute("SELECT * FROM Review ORDER BY Timestamp DESC LIMIT 5")
        slim(:review, locals:{showreview:showreview})
    end

    # Making a review
    #
    # @params ["text] params form for username     
    # @params ["header"] params form for password 
    # @session[:user] Information saved in database in session about user's username 
    # @session[:user_id] Information saved in database in session about user's user id
    #
    # @return Boolean [True] If validation of information and input in databse is made correct in relation to given requirements

    def makereview(params)
        if validate_info_makereview(params)
            review_text = params["text"]
            review_header = params["header"]
            review_username = session[:user]
            review_user_id = session[:user_id]
            db = database()
            db.execute("INSERT INTO review (text, username, user_id, header) VALUES (?,?,?,?)", review_text, review_username, review_user_id, review_header)
            redirect("/review")
        else 
            redirect("/failed")
        end 
    end
    
    # Obtaining information about the products to print them on the app
    #
    # @session ["user_id"] Identification linked to currently logged in user     
    #
    # @return [input] to database requirements are matched
        
    def product_info(params)
        db = database()
        return db.execute("SELECT * FROM products")
    end

    # Adding a product to the cart
    #
    # @session[:user_id] Allowing to add product to a cart based on currently logged in user     
    # @params[:product_id] Finding product in database based on its id
    #
    # @return query [input] to database if requirements are matched


    def add_to_cart(product_id, user_id)
        if validate_info_add_to_cart(params)
            db = database()
            db.execute("INSERT INTO cart (product_id,user_id) VALUES (?,?)", product_id, user_id)
        end
    end

    # Gathering information about the carts based on user id
    #
    # @session[:user_id] Allowing to find product id in cart based on currently logged in user     
    #
    # @return query [input] to database if requirements are matched

    def get_cart(user_id)
        db = database()
        db.execute('SELECT cart.product_id FROM cart WHERE cart.user_id = ?', user_id)
        show = db.execute('SELECT * FROM products INNER JOIN cart ON cart.product_id = products.product_id WHERE user_id = ?', user_id)
    end 

    # Showing information about cart based on user id
    #
    # @session[:user_id] Allowing to find product id in cart based on currently logged in user     
    #
    # @return query [query] to database if requirements are matched

    def cart_show_list(user_id)
        db = database()
        query = <<-SQL 
        SELECT name, price
        FROM products 
        INNER JOIN cart 
        ON products.product_id = cart.product_id 
        WHERE user_id = ?
        SQL
        db.execute(query, session[:user_id])
    end 

    # Changing username on currently logged in user
    #
    # @session[:user_id] Allowing to change username on currently logged in user by id    
    # @params["change_username"] Information user input from client regarding username 
    #
    # @return query [input] to database if requirements are matched

    def change_username(params, user_id) 
        if validate_info_change_username(params)
            db = database()
            db.execute("UPDATE users SET username = ? WHERE user_id = ?", params['change_username'], user_id)
            redirect('/profile')
        end
    end

    # Chaning password on currently logged in user
    #
    # @session[:user_id] Allowing to change password on currently logged in user by id    
    # @params["change_password"] Information user input from client about new password
    #
    # @return query [input] to database if requirements are matched

    def change_password(params, user_id ) 
        if validate_info_change_password(params)
            db = database()
            db.execute("UPDATE users SET password = ? WHERE user_id = ?", params['change_password'], user_id)
            redirect('/profile')
        end
    end

    # Error message if requested route is not found     
    #
    # @return slim :failed to database if requirements are matched

    error 404 do 
        redirect('/failed')
    end 
end


