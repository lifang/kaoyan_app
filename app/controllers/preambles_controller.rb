#encoding: utf-8
class PreamblesController < ApplicationController

  def sentence
    @category_id = params[:category_id].to_i
    @last_end_level = PracticeSentence.max_level(@category_id)
    @last_start_level = 1
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
    @category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @scores=cookies["#{Category::FLAG[@category]}"]
    redirect_to "/pretests/judge_cookie?category_id=#{@category}" if @scores.nil?
  end

  def jugde_url
    category=params[:category_id].to_i
    infos=cookies[Category::FLAG[category]]
    url=REDIRECT_URL+"?category=#{category}"
    is_redirect=true
    if infos
      info=infos.split(",")
      if info[0].to_i==0
        is_redirect=false
        url= "/pretests/test_words?category_id=#{category}"
      end
      if info[0].to_i!=0 and info[1].to_i==0
        is_redirect=false
        url= "/preambles/sentence?category_id=#{category}"
      end
      if info[0].to_i!=0 and info[1].to_i!=0 and info[2].to_i==0        
        if category!=Category::TYPE[:GRADUATE]
          is_redirect=false
          url="/pretests/listen?category_id=#{category}"
        end
      end
      if info[0].to_i!=0 and info[1].to_i!=0  and info[3].to_i==0
        if category==Category::TYPE[:GRADUATE]
          update_sentence_level(category, info[1].to_i, UserScoreInfo::LEVEL_INDEX[:SENTENCE])
        else
          update_sentence_level(category, info[2].to_i, UserScoreInfo::LEVEL_INDEX[:LINSTEN])
        end
      end
    else
      is_redirect=false
      url="/pretests/test_words?category_id=#{category}"
    end
    respond_to do |format|
      format.json {
        render :json=>{:url=>url,:redir=>is_redirect, :infos => infos}
      }
    end
  end


end
