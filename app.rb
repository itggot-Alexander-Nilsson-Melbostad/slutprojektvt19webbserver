require 'slim'
require 'sinatra'
require 'byebug'
require 'SQlite3'
require 'BCrypt'

require_relative './functions.rb'

enable :sessions

get("/") do
    slim(:index)
end

get("/kontakt") do
    slim(:kontakt)
end

get("/layout") do
    slim(:layout)
end

get("/login") do
    slim(:login)
end 

get("/ptsida") do
    slim(:ptsida)
end

get("/traningssida") do
    slim(:traningssida)
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

post("/login") do
    login(params)
end

post("/logout") do
    session.destroy
    redirect("/login")
end

post("/create") do
    create(params)
end

