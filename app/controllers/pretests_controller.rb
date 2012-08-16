#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json

  def test_words
    cookies[:user_id]=1
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    user_score=UserScoreInfo.find_by_user_id(cookies[:user_id])
    if user_score.nil?
      UserScoreInfo.create({:category_id=>category,:user_id=>cookies[:user_id]})
    else

    end
    @max_level=Word::MAX_LEVEL[Category::FLAG[category]]
    @level=(@max_level+1)/2
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
    UserScoreInfo.find_by_user_id(cookies[:user_id]).update_attributes(:all_start_level=>"#{params[:fact_level]}, , ")
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
    user_score=UserScoreInfo.find_by_user_id(cookies[:user_id])
    scores=user_score.all_start_level.split(",")
    scores[2]=params[:fact_level]
    user_score.update_attributes(:all_start_level=>"#{scores.join(",")}")
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def revoke_exam
    UserScoreInfo.find_by_user_id(cookies[:user_id]).destroy
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end
  
end
