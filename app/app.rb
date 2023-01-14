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
  ActiveRecord.default_timezone = :local

  get '/' do
    if session[:user_id] == nil
      @report = disp_reports()
      erb :index
    else
      u = User.find_by(user_id: session[:user_id])
      @uid = u.user_id
      @report = disp_reports()
      if session[:searched_result] != nil
        @searched_result = session[:searched_result]
      else
        @searched_result = ""
      end

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
  
  get '/users/:user_id' do
    @username = ""
    begin
      if is_user_id(params[:user_id])
        u = User.find_by(user_id: params[:user_id])
        @username = u.username
      end
    rescue => e
      p e
    end
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

  get '/report/new' do
    if session[:user_id] == nil
      redirect '/login'
    end

    erb :new_report
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

  get '/search' do
    if session[:user_id] == nil
      redirect '/login'
    end
    @searched_result = session[:searched_result]

    erb :search
  end

  post '/search' do
    if params[:searching_text] == ""
      redirect '/search'
    end

    begin
      s = ActiveRecord::Base.connection.execute("SELECT \"reports\".user_id, \"reports\".report, \"reports\".created_at
                                                 FROM reports WHERE (report LIKE'%#{params[:searching_text]}%')")

      searched_result = ""
      s.each do |si|
        searched_result += report_component(si)
      end
    rescue => e
      p e
    end
    session[:searched_result] = searched_result
    redirect '/search'
  end

  def disp_reports()
    report = ""
    begin
      (Report.all).each do |a|
        report += report_component(a)
      end
    rescue => e
      p e
    end
    return report
  end
  
  # r_report : record of report
  def report_component(r_report)
    user = User.find_by(user_id: r_report["user_id"])
    r = "<article class=\"report\">"
    r += "<span class=\"username\">#{user["username"]}</span>"
    r += "<span class=\"date\">#{extract_yyyyMMdd(r_report["created_at"])}</span>"
    r += "<p>#{r_report["report"]}</p>"
    r += "</article>"
    return r
  end

  def extract_yyyyMMdd(ymd)
    puts ymd.class
    if ymd.is_a?(String)
      ymd = Time.parse(ymd)
    end
    return ymd.strftime("%Y/%m/%d %H:%M")
  end

  def is_user_id(uid)
    if uid.match(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/) != nil
      return true
    end
    return false
  end

end
