require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'

require 'open-uri'
require 'net/http'
require 'json'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

get '/' do
    erb :index
end

get '/home' do
    @contents = User.all.order('id desc')
    @userposts = Post.all
    erb :home
end

get '/signup' do
    erb :sign_up
end

get '/mypage' do
    if current_user.nil?
        @useridposts = Post.none
        @favorites = Favorite.none
    else
        @useridposts = current_user.posts
        @favorites = current_user.favorite_posts
    end
    erb :mypage
end

get '/signin' do
    erb :sign_in
end

get '/post' do
    erb :new
end

get '/mypage/:id/following' do
    erb :following
end

get '/mypage/:id/follower' do
    erb :follower
end

get '/home/restaurant' do
    @contents = User.all.order('id desc')
    @userposts = Post.where(category: "飲食店")
    erb :home_restaurant
end

get '/home/cafe' do
    @contents = User.all.order('id desc')
    @userposts = Post.where(category: "カフェ")
    erb :home_cafe
end

get '/home/leisure' do
    @contents = User.all.order('id desc')
    @userposts = Post.where(category: "レジャー")
    erb :home_leisure
end

get '/home/beauty' do
    @contents = User.all.order('id desc')
    @userposts = Post.where(category: "ビューティー")
    erb :home_beauty
end

get '/home/hotel' do
    @contents = User.all.order('id desc')
    @userposts = Post.where(category: "ホテル")
    erb :home_hotel
end

get '/mypage/favorite' do
    if current_user.nil?
        @favorites = Favorite.none
    else
        @favorites = current_user.favorite_posts
    end
    erb :mypage_like
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/home'
end

post '/signup' do
    img_url = ''
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    end
    
    @user = User.create(name:params[:name], password:params[:password],
    password_confirmation:params[:password_confirmation],
    icon: img_url
    )
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/home'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

post '/home' do
    shopimg_url = ''
    if params[:file]
        shopimg = params[:file]
        tempfile = shopimg[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        shopimg_url = upload['url']
    end
    
    current_user.posts.create(shopname: params[:shopname], img: shopimg_url, 
    category: params[:category], assessment: params[:assessment], shopurl: params[:shopurl], comment: params[:comment], user_id: session[:user])
    redirect '/home'
end

get '/post/:id/del' do
    music = Post.find(params[:id])
    music.destroy
    redirect '/home'
end

get '/post/:id/edit' do
    @post = Post.find(params[:id])
    erb :edit
end

post '/post/:id' do
    music = Post.find(params[:id])
    music.comment = params[:comment]
    music.save
    redirect '/home'
end

get '/post/:id/like' do
    if Favorite.find_by(user_id: session[:user], post_id: params[:id]).nil?
        Favorite.create(user_id: session[:user], post_id: params[:id])
    end
    redirect '/home'
end

get '/post/:id/like_del' do
    like = Favorite.find_by(user_id: session[:user], post_id: params[:id])
    like.delete
    redirect '/home'
end

get '/home/:id/follow' do
    current_user.relationships.create(follower_id: session[:user], followed_id: params[:id])
    redirect '/home'
end

get '/home/:id/follow_del' do
    follow = current_user.relationships.find_by(followed_id: params[:id])
    follow.destroy
    follow.save
    redirect '/home'
end

