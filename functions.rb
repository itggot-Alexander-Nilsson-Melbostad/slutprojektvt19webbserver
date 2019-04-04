def login(params)
    state = false
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    result = db.execute("SELECT Username, Password, UserId, Authority, Nickname FROM users WHERE Username = '#{params["Username"]}'")
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:User] = params["Username"]
        session[:User_Id] = result[0]["UserId"]
        state = true
    else
        state = false
    end
    slim(:index, locals:{
        index: result
    })
end

