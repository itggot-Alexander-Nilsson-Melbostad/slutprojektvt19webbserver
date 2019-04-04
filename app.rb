require 'slim'
require 'sinatra'
require 'byebug'
require 'SQlite3'
require 'BCrypt'

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



