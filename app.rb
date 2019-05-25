require 'slim'
require 'sinatra'
require 'byebug'
require 'SQlite3'
require 'BCrypt'
require_relative './model.rb'
enable :sessions


include AppModule #Includes the model from model.rb

helpers do
    def get_error_login()
        msg = session[:msg_login_failed].dup
        session[:msg_login_failed] = nil
        return msg
    end
    def get_error_create()
        msg = session[:msg_create_failed].dup
        session[:msg_create_failed] = nil
        return msg
    end
    def get_error_review()
        msg = session[:msg_review_failed].dup
        session[:msg_review_failed] = nil
        return msg
    end
    def get_validate_error_login()
        msg = session[:validate_login_error_msg].dup
        session[:validate_login_error_msg] = nil
        return msg
    end
    def get_no_info_error_login()
        msg = session[:no_info_error_msg].dup
        session[:no_info_error_msg] = nil
        return msg
    end 
end

# Configures the unsecured paths that are locked in the application
configure do
    set :unsecured_paths, ['/', '/login', '/new', '/create']
end

# Securing the current user to be logged in
before do
    unless settings.unsecured_paths.include?(request.path)
        if session[:user_id].nil?
            redirect('/')
        end
    end
end

# Displays starting page
#
get("/") do
    slim(:index)
end

# Selects information about reviews from databse to print
#
get("/review") do
    showreview = review()
    slim(:review, locals:{showreview: showreview})
end

# Displays static header and footer on all different routes
# 
get("/layout") do
    slim(:layout)
end

# Displays login page
# 
get("/login") do     
    slim(:login)
end 

# Displays profile page
#
get("/profile") do
    slim(:profile)
end

# Displays training page
#
get("/traning") do
    slim(:traning)
end

# Displays outside gym page
#
get("/utegym") do
    slim(:utegym)
end

# Displays create new user page
#
get("/new") do
    slim(:new)
end

# Displays error page when login does not match given requirements 
#
get("/loginfailed") do
    slim(:loginfailed)
end

# Displays checkout page
#
get("/checkout") do
    slim(:checkout)
end

# Displays the webshop and shows current cart if one exists based on user id 
#
get("/webshop") do
    info = product_info(params)
    show = get_cart(session[:user_id])
    slim(:webshop, locals:{info: info,show: show})
end

# Displays page for successful logout
#
get("/logout") do
    slim(:logout)
end

# Attempts to login and redirects to '/index' or back if failedw
#
# @param[string] Information from login form
#
#@see Model#login
post("/login") do
    result = login(params)
    if result[:validate_login_error]
        session[:validate_login_error_msg] = result[:validate_login_error_msg]
        redirect back
    elsif result[:error_login]
        session[:msg_login_failed] = result[:message_login]
        redirect back
    elsif
        result[:no_info_error]
        session[:no_info_error_msg] = result[:no_info_error_msg]
        redirect back
    else
        session[:user_id] = result[:user_id]
        session[:user] = result[:user]
        redirect('/')
    end
end

# Signs out and redirects to '/logout'
#
#@see Model#logout
post("/logout") do
    session.destroy
    redirect("/logout")
end

# Attempts to create account
#
# @param[string] Information from register form 
#
#@see Model#create
post("/create") do
    result = create(params)
    if result[:error_create]
        session[:msg_create_failed] = result[:message_create]
        redirect back
    else
        session[:nickname] = result[:nickname]
        redirect('/')
    end
end

# Empties cart based on user id
#
# session[:user_id] user's identification
#
#@see Model#clearcart
post("/clearcart") do
    clearcart(session[:user_id])
    redirect("/webshop")
end

# Attempts to create a review
#
# @param[string] Information from "Make review" form
#
#@see Model#makereview
post("/makereview") do
    result = makereview(params)
    if result[:error_review]
        session[:msg_review_failed] = result[:messsage_create]
        redirect back
    else
        redirect("/review")
    end
end 


# Attempts to add product to cart
#
# param[:product_id] Identification from product
# session[:user_id] User identification
#
#@see Model#add_to_cart
post('/add_to_cart') do
    add_to_cart(params[:product_id], session[:user_id])
    redirect('/webshop')
end


# Attempts to show cart based on user id
#
# sessiom[:user_id] User's identification
#
#@see Model#cart_show_list
post('/cart_show_list') do
    cart_show_list(user_id) 
end 

# Attempts to change current username based on user id 
#
# sessiom[:user_id] User's identification
# @param["username"] New username
#
#@see Model#change_username
post('/change_username_route') do
    change_username(params, session[:user_id])
    redirect('/profile')
end

# Attempts to show cart based on user id
#
# sessiom[:user_id] User's identification
# @param["password"] New password 
#
#@see Model#change_password
post('/change_password_route') do
    change_password(params, session[:user_id])
    redirect('/profile')
end

# Error message if requested route is not found     
#
# @return slim :failed to database if requirements are matched
error 404 do 
    redirect('/failed')
end 

