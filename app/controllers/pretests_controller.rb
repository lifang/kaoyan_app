#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json
  include LoginHelper
  
  def test_words
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @max_level=Word::MAX_LEVEL[Category::FLAG[category]]
    @level=((@max_level.to_f + 1)/2).round
    @words=Word.get_items_by_level(@level, 4)
  end
 

  def other_words
    if params[:limit_ids]==""
      @words=Word.get_items_by_level(params[:level].to_i, 4)
    else
      @words=Word.get_items_by_level(params[:level].to_i, 4, params[:limit_ids].chop)
    end
    respond_with do |format|
      format.js
    end
  end


  def listen
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    @end_level=PracticeSentence::SENTENCE_MAX_LEVEL[Category::FLAG[category]]
    @user_level=(@end_level + 1)/2
    @listen = PracticeSentence.find(:first, :conditions => [" types= ? and level = ?", PracticeSentence::TYPES[:LINSTEN], @user_level], :order => "rand()")
  end

  def other_listens
    if params[:limit_ids]==""
      pars=["level = ? and types= ?",
        params[:level],PracticeSentence::TYPES[:LINSTEN]]
    else
      pars=["level = ? and types= ? and id not in (?)",
        params[:level],PracticeSentence::TYPES[:LINSTEN],params[:limit_ids].chop]
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
    cookies[Category::FLAG[category]]=nil
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
