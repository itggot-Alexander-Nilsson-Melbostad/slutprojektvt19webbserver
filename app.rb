require 'slim'
require 'sinatra'
require 'byebug'
require 'SQlite3'
require 'BCrypt'

require_relative './functions.rb'

enable :sessions

configure do
    set :unsecured_paths, ['/', '/login', '/new']
end

before do
    unless settings.unsecured_paths.include?(request.path)
        if session[:user_id].nil?
            redirect('/')
        end
    end
end


get("/") do
    slim(:index)
end

get("/review") do
    review()
end

get("/layout") do
    slim(:layout)
end

get("/login") do
    slim(:login)
end 

get("/profile") do
    slim(:profile)
end

get("/traning") do
    slim(:traning)
end

get("/utegym") do
    slim(:utegym)
end

get("/new") do
    slim(:new)
end

get("/loginfailed") do
    slim(:loginfailed)
end

get("/checkout") do
    slim(:checkout)
end

get("/webshop") do
    info = product_info(params)
    show = get_cart(session[:user_id])
    slim(:webshop, locals:{info: info,show: show})
end

get("/logout") do
    slim(:logout)
end

post("/login") do
    login(params)
end

post("/logout") do
    session.destroy
    redirect("/logout")
end

post("/create") do
    create(params)
end

post("/clearcart") do
    clearcart(session[:user_id])
end

post("/makereview") do
    makereview(params)
end

post('/addtocart') do
    addtocart(params[:product_id], session[:user_id])
    redirect('/webshop')
end

post('/cart_show_list') do
    cart_show_list(user_id) 
end 

post('/change_username_route') do
    change_username(params, session[:user_id])
end

post('/change_password_route') do
    change_password(params, session[:user_id])
end


