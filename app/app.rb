require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'digest/sha2'
require 'cgi'
require 'securerandom'

set :environment, :production
set :session_store, Rack::Session::Cookie

use Rack::Session::Cookie,
  :key => 'rack.session',
  :expire_after => 60,
  :secret => Digest::SHA256.hexdigest(rand.to_s)

class User < ActiveRecord::Base
end

class App < Sinatra::Base
  enable :sessions

  get '/' do
    if session[:user_id] == nil
      erb :index
    else
      u = User.find_by(user_id: session[:user_id])
      @u = u.username
      erb :index4login
    end
  end
  
  get '/login' do
    erb :login
  end
  
  get '/logout' do
    session.clear
    redirect '/'
  end
  
  get '/signup' do
    @errormsg = session[:errormsg]
    erb :signup
  end

  post '/signup' do
    a = User.all
    maxid = 0
    a.each do |ai|
      if ai.id > maxid
        maxid = ai.id
      end
      if ai.username == params[:username]
        session[:errormsg] = "既に登録されているユーザー名です"
        redirect '/signup'
      end
    end

    begin
      u = User.new
      u.id = maxid + 1
      u.user_id = SecureRandom.uuid
      u.username = params[:username]
      u.passwd = Digest::SHA256.hexdigest(params[:passwd])
      u.email = params[:email]
      u.save
    rescue => e
      p e
    end

    redirect '/login'
  end
 
  get '/failure' do
    session.clear
    erb :failure
  end
  
  get '/contents' do
    if session[:user_id] != nil
      erb :index4login
    end
  end
  
  get '/:username' do
    @username = params[:username]
    erb :profile
  end
  
  post '/auth' do
    name = params[:username]
    passwd = params[:passwd]
    
    begin
      a = User.find_by(username: name)
      ipasswd_hashed = Digest::SHA256.hexdigest(passwd)
      if a.passwd == ipasswd_hashed
        session[:user_id] = a.user_id
        p session[:user_id]
        redirect '/'
      end
      redirect '/failure'
    end
  end
  
end
