#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json

  def test_words
    cookies[:user_id]=2
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    user_score=UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id])
    if user_score.nil?
      UserScoreInfo.create({:category_id=>category,:user_id=>cookies[:user_id]})
    end
    @max_level=Word::MAX_LEVEL[Category::FLAG[category]]
    @level=((@max_level+1).to_f/2).round
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
  
end
