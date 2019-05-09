def validate_info_create(params)
    if params["username"].nil? || params["password"].nil? || params["nickname"].nil? 
        return false
    else
        return true 
    end
end 

def validate_info_makereview(params)
    if params["review_text"].nil? || params["review_username"].nil? || params["review_user_id"].nil? || params["review_header"].nil?
        return false
    else 
        return true
    end
end

def validate_info_addtocart(params)
    if session[:product_id].nil?
        return false
    else 
        return true
    end
end

def validate_info_change_username(params)
    if params["change_username"].nil?
        return false
    else 
        return true
    end
end 

def validate_info_change_password(params)
    if params["change_password"].nil?
        return false
    else 
        return true
    end
end 

def validate_info_login(params)
    if params["username"].nil? || params["username"].length > 10 || params["username"].length < 2 
        return false
    else 
        return true
    end
end 
    

def database()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    db
end

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

def clearcart(user_id)
    db = database()
    db.execute("DELETE FROM cart WHERE cart.user_id = ?", user_id)
    redirect("/webshop")
end

def review()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    showreview = db.execute("SELECT * FROM Review ORDER BY Timestamp DESC LIMIT 5")
    slim(:review, locals:{showreview:showreview})
end

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
    
def product_info(params)
    db = database()
    return db.execute("SELECT * FROM products")
end

def addtocart(product_id, user_id)
    if validate_info_addtocart(params)
        db = database()
        db.execute("INSERT INTO cart (product_id,user_id) VALUES (?,?)", product_id, user_id)
    end
end

def get_cart(user_id)
    db = database()
    db.execute('SELECT cart.product_id FROM cart WHERE cart.user_id = ?', user_id)
    show = db.execute('SELECT * FROM products INNER JOIN cart ON cart.product_id = products.product_id WHERE user_id = ?', user_id)
end 

def cart_show_list(user_id)
    db = database()
    query = <<-SQL 
    SELECT name, price
    FROM products 
    INNER JOIN cart 
    ON products.product_id = cart.product_id 
    WHERE user_id = ?
    SQL
    db.execute(query, session[user_id])
end 

def change_username(params, user_id) 
    if validate_info_change_username(params)
        db = database()
        db.execute("UPDATE users SET username = ? WHERE user_id = ?", params['change_username'], user_id)
        redirect('/profile')
    end
end

def change_password(params, user_id ) 
    if validate_info_change_password(params)
        db = database()
        db.execute("UPDATE users SET password = ? WHERE user_id = ?", params['change_password'], user_id)
        redirect('/profile')
    end
end

error 404 do 
    redirect('/failed')
end 



