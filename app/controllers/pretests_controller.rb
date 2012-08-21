#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json
  include LoginHelper
  
  def test_words
    cookies[:user_id]=2
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    user_score=UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id])
    if user_score.nil?
      UserScoreInfo.create({:category_id=>category,:user_id=>cookies[:user_id]})
    end
    @max_level=Word::MAX_LEVEL[Category::FLAG[category]]
    @level=((@max_level).to_f/2).round
    @words=Word.get_items_by_level(@level, params[:category_id], 4)
  end


  def other_words
    if params[:limit_ids]==""
      @words=Word.get_items_by_level(params[:level].to_i, params[:category_id], 4)
    else
      @words=Word.get_items_by_level(params[:level].to_i, params[:category_id], 4,params[:limit_ids].chop)
    end
    respond_with do |format|
      format.js
    end
  end


  def level_record
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id]).update_attributes(:all_start_level=>"#{params[:fact_level]},0,0")
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def listen
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @end_level=PracticeSentence::SENTENCE_MAX_LEVEL[Category::FLAG[category]]
    @user_level=(@end_level + 1)/2
    @listen = PracticeSentence.find(:first, :conditions => ["level = ? and types= ? and category_id=?", @user_level,PracticeSentence::TYPES[:LINSTEN],category], :order => "rand()")
  end

  def other_listens
    if params[:limit_ids]==""
      pars=["level = ? and types= ?  and category_id=?",
        params[:level],PracticeSentence::TYPES[:LINSTEN],params[:category_id]]
    else
      pars=["level = ? and types= ? and id not in (?) and category_id=?",
        params[:level],PracticeSentence::TYPES[:LINSTEN],params[:limit_ids].chop,params[:category_id]]
    end
    @listen=PracticeSentence.find(:first, :conditions => pars, :order => "rand()")
    respond_with do |format|
      format.js
    end
  end

  def level_listen
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    UserScoreInfo.update_sentence_level(category, cookies[:user_id], params[:fact_level].to_i, UserScoreInfo::LEVEL_INDEX[:LINSTEN])
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def revoke_exam
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id]).destroy
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def baidu_connect
    @api_key = LoginHelper::BAIDU_API_KEY
    @baidu_callback =LoginHelper::BAIDU_CALLBACK
    if params[:bd_user] && params[:bd_user]!="0"
      @user=User.find_by_code_id_and_code_type(params[:bd_user],"baidu")
      if @user
        ActionLog.login_log(@user.id)
        cookies[:user_id]=@user.id
        cookies[:user_name]=@user.username
        cookies.delete(:user_role)
        user_order(Category::TYPE[:GRADUATE], cookies[:user_id].to_i)
        redirect_to "/?category_id=#{Category::TYPE[:GRADUATE]}"
        return false
      end
    end

  end

  def respond_baidu
    http_route="/oauth/2.0/token?grant_type=authorization_code&code=#{params["code"]}&client_id=#{LoginHelper::BAIDU_API_KEY}
    &client_secret=#{LoginHelper::BAIDU_SERECT_KEY}&redirect_uri=#{LoginHelper::BAIDU_CALLBACK}"
    access_token=create_get_http(LoginHelper::BAIDU_API,http_route)
    token_route="/rest/2.0/passport/users/getLoggedInUser?access_token=#{access_token["access_token"]}"
    ret_user = create_get_http(LoginHelper::BAIDU_API,token_route)
    @user=User.find_by_code_id_and_code_type("#{ret_user["uid"]}","baidu")
    if @user.nil?
      @user=User.create(:code_id=>ret_user["uid"],:code_type=>'baidu',:name=>ret_user["uname"],
        :username=>ret_user["uname"], :access_token=>access_token, :end_time=>Time.now+access_token["expires_in"].to_i.seconds, :from => User::U_FROM[:APP ])
    else
      ActionLog.login_log(@user.id)
      if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
        @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+access_token["expires_in"].to_i.seconds)
      end
    end
    cookies[:user_id]=@user.id
    cookies[:user_name]=@user.username
    cookies.delete(:user_role)
    user_order(Category::TYPE[:GRADUATE], cookies[:user_id].to_i)
    render :inline=>"<script type='text/javascript'>window.parent.location.href='/?category=#{Category::TYPE[:GRADUATE]}'</script>"
  end
  
end
