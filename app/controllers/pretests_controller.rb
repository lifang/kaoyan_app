#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json
  include LoginHelper
  
  def test_words
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @max_level=Word::MAX_LEVEL[Category::FLAG[category]]
    @level=((@max_level.to_f + 1)/2).round
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
    update_sentence_level(category, params[:fact_level].to_i, UserScoreInfo::LEVEL_INDEX[:LINSTEN])
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

  def cet_four
    @category = Category::TYPE[:CET4]
    render "index"
  end

  def cet_six
    @category = Category::TYPE[:CET6]
    render "index"
  end

  def graduate
    @category = Category::TYPE[:GRADUATE]
    render "index"
  end


  def judge_cookie
    category=params[:category_id].to_i
    infos=cookies[Category::FLAG[category]]
    if infos
      info=infos.split(",")
      if info[0].to_i==0
        redirect_to "/pretests/test_words?category_id=#{category}"
      elsif info[1].to_i==0
        redirect_to "/preambles/sentence?category_id=#{category}"
      elsif info[2].to_i==0 and category!=Category::TYPE[:GRADUATE]
        redirect_to "/pretests/listen?category_id=#{category}"
      elsif info[3].to_i==0
        if category==Category::TYPE[:GRADUATE]
          update_sentence_level(category, info[1].to_i, UserScoreInfo::LEVEL_INDEX[:SENTENCE])
        else
          update_sentence_level(category, info[2].to_i, UserScoreInfo::LEVEL_INDEX[:LINSTEN])
        end
        redirect_to "/preambles/test_result?category_id=#{category}"
      else
        redirect_to "/preambles/test_result?category_id=#{category}"
      end
    else
      redirect_to "/pretests/test_words?category_id=#{category}"
    end
  end
  
end
