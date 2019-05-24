module AppModule
    # Validates information upon creating account
    #
    # @param [Hash] params info for creating account 
    # @option param [String] params form for username
    # @option param [String] params form for password 
    # @option param [String] params form for nickname
    #
    # @return Boolean [True] if data matches requirements for information input
    def validate_info_create(params)
        if params["username"].nil? || params["password1"].nil? || params["password2"].nil? || params["nickname"].nil? || params["password1"] != params["password2"]  
            return false
        else
            return true 
        end
    end 
    
    # Validates information upon making a review
    #
    # @param [Hash] Total hash for information about creating a review
    # @option params [String] params form for the main content input
    # @option params [String] params form for username 
    # @option params [String] params form for users identification on given review
    # @option params [String] params form for main header in created review
    #
    # @return [Boolean] if data matches requirements for information input
    def validate_info_makereview(params)
        if params["text"].nil? || params["header"].nil?
            return false
        else 
            return true
        end
    end
    
    # Validates product upon adding a product to the cart
    #
    # @param :product_id [Integer] the product's id located in database 
    #
    # @return [Boolean] if the paroduct id exists in database
    def validate_info_add_to_cart(params)
        if params[:product_id].nil?
            return false
        else 
            return true
        end
    end
    
    # Validates information upon changing username
    #
    # @param [String] The information given in form of changing username 
    #
    # @return [Boolean] if the username input is an actual username and not for example nil
    def validate_info_change_username(params)
        if params["change_username"].nil?
            return false
        else 
            return true
        end
    end 
    
    # Validates information upon changing password
    #
    # @param [String] The information given in form of changing username 
    #
    # @return [Boolean] if the password input is an legitimate password and not for example nil
    def validate_info_change_password(params)
        if params["change_password"].nil?
            return false
        else   
            return true
        end
    end 
    
    # Validates information upon logging in
    #
    # @param [String] params form for username
    #
    # @return [Boolean]  if data matches requirements for information input (>10 <2 != nil)
    def validate_info_login(params)
        if params["username"].nil? || params["username"].length > 10 || params["username"].length < 2 || params["password"].nil? || params["password"].length < 2 || params["password"].length > 10
            return false
        else 
            return true
        end
    end 
    
    # Calling upon database file from module SQLlite3
    #
    # @return [Boolean] if data matches requirements for information input (>10 <2 != nil)
    def database()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        db
    end
    
    # logging in 
    #
    # @param [Hash] params form for username
    # @option params [String] params form for username     
    # @option params [String] params form for password 
    # @option params [String] params form for users identification on given login
    # @option params [String] params form for nickname on logging in
    #
    # @return [Hash] if data matches requirements for information input
    #   * :error_login [Boolean] Wheter an error occured when logging in
    #   * :user_id [Integer] user identification
    #   * :nickname [String] user nickname
    #   * :user [String] user's username
    #   * :message_login [String] The given error message when creating an account
    def login(params)
        if validate_info_login(params)
            db = database()
            result = db.execute("SELECT username, password, user_id, authority, nickname FROM users WHERE username = ?", params["username"])
            if result.length > 0
                if BCrypt::Password.new(result[0]["password"]) == params["password"] && result[0]["username"] == params["username"]
                    return{
                        error_login: false,
                        user_id: result[0]["user_id"],
                        user: params["username"]
                    }
                else
                    return {
                        error_login: true,
                        message_login: "Password did not match username"
                    }
                end
            else
                return {
                    no_info_error: true,
                    no_info_error_msg: "No such user"
                }
            end
        else
            return{
                validate_login_error: true,
                validate_login_error_msg: "Password has to be longer than 2 charachters and smaller than 10 charachters, same goes for username"
            }
        end
    end
    
    # Create an account 
    #
    # @param [Hash] Total information for creating an account
    # @option params [String] params form for username         
    # @option params [String] params form for password 
    # @option params [String] params form for nickname on logging in
    #
    # @return [Hash] input to database requirements are matched
    #   * :error_create [Boolean] Wheter an error occured¨
    #   * :user_id [Integer] user identification
    #   * :nickname [String] user nickname
    #   * :user [String] user's username
    #   * :message_create [String] The given error message when creating an account
    def create(params)
        if validate_info_create(params)
            db = database()
            new_name = params["username"] 
            new_password = params["password1"]
            new_nickname = params["nickname"]
            new_password_hash = BCrypt::Password.create(new_password)
            db.execute("INSERT INTO users (username, password, authority, nickname) VALUES (?,?,?,?)", new_name, new_password_hash, 1, new_nickname)
            result = db.execute("SELECT * FROM users")
            return {
                error_create: false,
                user_id: result[0]["user_id"],
                nickname: params["nickname"],
                user: params["username"]
            }
        else
            return {
                error_create: true,
                message_create: "Invalid credentials for creating an account"
            }
        end  
    end
    
    # Clearing users cart
    #
    # @param [Integer] Identification linked to currently logged in user     
    #
    # @return [input] to database requirements are matched
    def clearcart(user_id)
        db = database()
        db.execute("DELETE FROM cart WHERE cart.user_id = ?", user_id)
    end
    
    # Obtaining information about the reviews to print them on the app
    #
    # @param [integer] Identification linked to currently logged in user     
    #
    # @return [input] to database requirements are matched
    def review()
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        db.execute("SELECT * FROM Review ORDER BY Timestamp DESC LIMIT 5")
    end
    
    # Making a review
    #
    # @param [Hash] total information when making a review     
    # @option params [String] params form for general text in review 
    # @option params [String] params form for header in review 
    # @option params [String] Information saved in database in session about user's username 
    # @option params [Integer] Integer saved in database in session about user's user id
    #
    # @return [Boolean] If validation of information and input in databse is made correct in relation to given requirements
    def makereview(params)
        if validate_info_makereview(params)
            db = database()
            review_text = params["text"]
            review_header = params["header"]
            review_username = session[:user]
            review_user_id = session[:user_id]
            db.execute("INSERT INTO review (text, username, user_id, header) VALUES (?,?,?,?)", review_text, review_username, review_user_id, review_header)
            return {
                error_review: false,
                review_text: params["text"],
                review_header: params["header"],
                review_username: params["username"] 
            }
        else
            return {
                error_review: true,
                message_review: "Atleast one input field is empty"
            }  
        end 
    end
    
    # Obtaining information about the products to print them on the app
    #
    # @param [String Information from database about products       
    #
    # @return [input] to database requirements are matched
    def product_info(params)
        db = database()
        return db.execute("SELECT * FROM products")
    end
    
    # Adding a product to the cart
    #
    # @param [Hash] Total information about carts based on user id
    # @option params [integer] User's identification
    # @option params [Integer] Finding product in database based on product id
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
    # @param [Integer] Allowing to find product id in cart based on currently logged in user     
    #
    # @return query [input] to database if requirements are matched
    def get_cart(user_id)
        db = database()
        db.execute('SELECT cart.product_id FROM cart WHERE cart.user_id = ?', user_id)
        show = db.execute('SELECT * FROM products INNER JOIN cart ON cart.product_id = products.product_id WHERE user_id = ?', user_id)
    end 
    
    # Showing information about cart based on user id
    #
    # @param [Integer] Allowing to find product id in cart based on currently logged in user     
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
    # @param [Hash] Total inforamtion about current user and username
    # @option params [Integer] Allowing to change username on currently logged in user by id    
    # @option params [String] Information user input from client regarding username 
    #
    # @return query [input] to database if requirements are matched
    def change_username(params, user_id) 
        if validate_info_change_username(params)
            db = database()
            db.execute("UPDATE users SET username = ? WHERE user_id = ?", params['change_username'], user_id)
        end
    end
    
    # Changing password on currently logged in user
    #
    # @param [Hash] total amount of information about user id and password
    # @option params [Integer] Allowing to change password on currently logged in user by id    
    # @option params [String] Information user input from client about new password
    #
    # @return query [input] to database if requirements are matched
    def change_password(params, user_id ) 
        if validate_info_change_password(params)
            db = database()
            db.execute("UPDATE users SET password = ? WHERE user_id = ?", params['change_password'], user_id)
        end
    end
end


