require 'slim'
require 'sinatra'
require 'byebug'
require 'SQlite3'
require 'BCrypt'
require_relative './model.rb'
enable :sessions

#Includes the model from model.rb
include AppModule 



# Configures the unsecured paths that are locked in the application
configure do
    set :unsecured_paths, ['/', '/login', '/new']
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
    review()
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

# Attempts to login and redirects to '/index', else '/loginfailed'
#
# @param[string] Information from login form
#
#@see Model#login
post("/login") do
    login(params)
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
    create(params)
end

# Empties cart based on user id
#
# session[:user_id] user's identification
#
#@see Model#clearcart
post("/clearcart") do
    clearcart(session[:user_id])
end

# Attempts to create a review
#
# @param[string] Information from "Make review" form
#
#@see Model#makereview
post("/makereview") do
    makereview(params)
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
end

# Attempts to show cart based on user id
#
# sessiom[:user_id] User's identification
# @param["password"] New password 
#
#@see Model#change_password
post('/change_password_route') do
    change_password(params, session[:user_id])
end


