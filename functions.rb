def login(params)
    state = false
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT Username, Password, UserId, Authority, Nickname FROM users WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:User] = params["Username"]
        session[:User_Id] = result[0]["UserId"]
        redirect("/index")
    else
        redirect("/loginfailed")
    end
    slim(:index, locals:{
        index: result
    })
end

def create(params)
    db =SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    new_name = params["Username"] 
    new_password = params["Password1"]
    new_nickname = params["Nickname"]
    if params["Password1"] == params["Password2"]
        new_password_hash = BCrypt::Password.create(new_password)
        db.execute("INSERT INTO users (Username, Password, Authority, Nickname) VALUES (?,?,?,?)", new_name, new_password_hash, 1, new_nickname)
        redirect("/")
    else
        redirect("/loginfailed")
    end
end