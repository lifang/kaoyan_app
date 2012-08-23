#encoding: utf-8
class PreamblesController < ApplicationController

  def sentence
    puts "-----------------------"    
    @category_id = params[:category_id].to_i
    puts cookies["#{Category::FLAG[@category_id]}"]
    puts "#{Category::FLAG[@category_id]}"
    
    @last_end_level = PracticeSentence.max_level(@category_id)
    @last_start_level = 2
    @user_level = ((@last_end_level + @last_start_level).to_f/2).round
    @sentence = PracticeSentence.find(:first, :conditions => ["level = ?", @user_level], :order => "rand()")
    @sentence_ids = [@sentence.id]
  end

  def next_sentence
    @category_id = params[:category_id].to_i
    @sentence_ids = []
    alreay_ids = params[:sentence_ids].split(",").collect { |i| i.to_i }
    @level_change_flag = true
    @is_end = false
    if params[:true_time].to_i == 3  #当用户连对3次
      @last_start_level = params[:current_level].to_i
      @last_end_level = params[:l_end_level].to_i
      @user_level = ((@last_end_level.to_f + @last_start_level.to_f)/2).round      
      @is_end = true if @user_level == @last_end_level.to_i #用户将要练习的等级是上一次错的等级，那么用户确定为当前级
    elsif params[:error_time].to_i == 2 or (alreay_ids.length == 4 and params[:error_time].to_i == 1) or
        (alreay_ids.length >= 5 and params[:true_time].to_i < 2)  #当用户连错2次，或者连对的次数不可能超过3次
      @last_start_level = params[:l_start_level].to_i
      @last_end_level = params[:current_level].to_i
      @user_level = ((@last_start_level.to_f + @last_end_level.to_f)/2).round
      if @user_level == @last_end_level or @user_level == @last_start_level #用户将要练习的等级是上一次对的等级，那么用户确定为当前级
        @user_level = @last_start_level
        @is_end = true
      end      
    else
      @user_level = params[:current_level].to_i
      @sentence_ids = alreay_ids
      @last_end_level = params[:l_end_level]
      @last_start_level = params[:l_start_level]
      @level_change_flag = false
    end
    unless @is_end
      sql = @sentence_ids.blank? ? "level = ?" : "id not in (#{alreay_ids.join(",")}) and level = ?"
      @sentence = PracticeSentence.find(:first, :conditions => [sql,  @user_level],
        :order => "rand()")
      @sentence_ids << @sentence.id
    else
      update_sentence_level(@category_id, @user_level, UserScoreInfo::LEVEL_INDEX[:SENTENCE])      
    end
    respond_to do |format|
      format.js
    end
  end

  def test_result
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @user_score=UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id])
  end

  def create_plan
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    plans=UserPlan.calculate_user_plan_info(cookies[:user_id], Category::TYPE[Category::FLAG[category]], params[:target_score].to_i)
    plans.merge!(:DAYS=>UserPlan.package_level(Category::TYPE[Category::FLAG[category]]))
    @user_plan={}
    plans.each do |k,v|
      @user_plan["#{k}"]="#{v}"
    end
    respond_to do |format|
      format.js
    end
  end

  def init_plan
    user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category_id].to_i, cookies[:user_id].to_i)
    plan_infos=ActiveSupport::JSON.decode params[:plan_infos]
    data_info={}
    plan_infos.each do |k,v|
      data_info[:"#{k}"]=v.to_i
    end
    UserPlan.init_plan(user_score_info, data_info, cookies[:user_id].to_i, params[:category_id].to_i)
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def update_user
    user=User.find(cookies[:user_id])
    infos={:email=>params[:p_email]}
    infos.merge!(:name=>params[:p_name]) unless params[:p_name]==""
    infos.merge!(:remarks=>"#{user.remarks} qq:#{params[:p_qq]}") unless params[:p_qq]==""
    user.update_attributes(infos)
    redirect_to "/preambles/follows?category_id=#{params[:category_id]}"
  end

  def follows
    @user=User.find(cookies[:user_id])
  end
  
end
