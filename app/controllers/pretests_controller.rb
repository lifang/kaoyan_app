#encoding: utf-8
class PretestsController < ApplicationController
  respond_to :html, :xml, :json

  def test_words
    @level=(params[:min_level].to_i+params[:max_level].to_i+1)/2
    @words=Word.get_items_by_level(@level, Category::TYPE[:GRADUATE], 4)
  end


  def other_words
    @words=Word.get_items_by_level(params[:level].to_i, Category::TYPE[:GRADUATE], 4,params[:limit_ids].chop)
    respond_with do |format|
      format.js
    end
  end


  def level_record
    cookies[:user_id]=1
    pams={:category_id=>Category::TYPE[:GRADUATE],:user_id=>cookies[:user_id],:all_start_level=>params[:fact_level]}
    UserScoreInfo.create(pams)
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end
end
