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

  # エラーメッセージ
  e = ""

  get '/' do
    if session[:user_id] == nil
      @report = disp_reports()
      erb :index
    else
      @uid = session[:user_id]
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
    user_id = params[:user_id]
    begin
      if is_user_id(user_id)
        u = User.find_by(user_id: user_id)
        @username = u.username
        @uid = user_id

        @report = disp_reports_with_user_id(user_id)
      end
    rescue => e
      p e
    end
    erb :profile
  end

  get '/users/:user_id/change_username' do
    if session[:user_id] == nil
      redirect '/login'
    end

    user_id = params[:user_id]
    if !is_user_id(user_id)
      redirect '/'
    end

    @uid = user_id
    erb :change_username
  end

  post '/users/:user_id/change_username' do
    if session[:user_id] == nil
      redirect '/login'
    end

    user_id = params[:user_id]
    if !is_user_id(user_id)
      redirect '/'
    end

    begin
      user = User.find_by(user_id: user_id)
      user.update(username: params[:new_username])
    end
    redirect "/users/#{user_id}"
  end
 
  get '/users/:user_id/change_passwd' do
    if session[:user_id] == nil
      redirect '/login'
    end

    user_id = params[:user_id]
    if !is_user_id(user_id)
      redirect '/'
    end

    @uid = user_id
    erb :change_passwd
  end

  post '/users/:user_id/change_passwd' do
    new_passwd = params[:new_userpasswd]
    begin
      user = User.find_by(user_id: params[:user_id])
      hashed_new_passwd = Digest::SHA256.hexdigest(new_passwd)
      user.update(passwd: hashed_new_passwd)
    end

    session.clear
    redirect '/login'
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
    @uid = session[:user_id]

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

  s_result = ""
  get '/search' do
    if session[:user_id] == nil
      redirect '/login'
    end
    @searched_result = s_result
    @uid = session[:user_id]
    @err = e

    erb :search
  end

  post '/search' do
    if params[:searching_text] == ""
      redirect '/search'
    end

    begin
      s = ActiveRecord::Base.connection.execute("SELECT \"reports\".user_id, \"reports\".report, \"reports\".created_at FROM reports 
        WHERE (report LIKE'%#{params[:searching_text]}%')")

      s_result = ""
      if s.size == 0
        e = '検索結果がありません'
      end
      s.each do |si|
        s_result += report_component(si)
      end
    rescue => e
      p e
    end
    @searched_result = s_result
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

  def disp_reports_with_user_id(user_id)
    report = ""
    begin
      (Report.where(user_id: user_id)).each do |a|
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
