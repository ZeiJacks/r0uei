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

class Report < ActiveRecord::Base
end

class App < Sinatra::Base
  enable :sessions

  get '/' do
    if session[:user_id] == nil
      @report = disp_reports()
      erb :index
    else
      u = User.find_by(user_id: session[:user_id])
      @u = u.username
      @report = disp_reports()

      erb :index4login
    end
  end
  
  get '/login' do
    @notfounduser = session[:notfounduser]
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
      hashed_passwd = Digest::SHA256.hexdigest(passwd)
      a = User.find_by(username: name, passwd: hashed_passwd)
      if a == nil
        session[:notfounduser] = "ユーザー名かパスワードが間違っています"
        redirect '/login'
      end
      session[:user_id] = a.user_id

      redirect '/'
    end
  end

  post '/report' do
    if session[:user_id] == nil
      redirect '/login'
    end
    begin
      r = Report.new
      r.user_id = session[:user_id]
      r.report = CGI.escapeHTML(params[:report])
      r.created_at = Time.now
      r.save
    rescue => e
      p e
    end

    redirect '/'
  end

  def disp_reports()
    report = ""
    begin
      (Report.all).each do |a|
        report += "<article>"
        report += "<p>#{a.report}</p>"
        report += "</article>"
      end
    rescue => e
      p e
    end
    return report
  end
  
end
