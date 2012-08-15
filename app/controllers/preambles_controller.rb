class PreamblesController < ApplicationController

  def sentence    
    @end_level = case params[:category_id].to_i
    when Category::TYPE[:CET4]
      PracticeSentence::SENTENCE_MAX_LEVEL[:CET4]
    when Category::TYPE[:CET6]
      PracticeSentence::SENTENCE_MAX_LEVEL[:CET6]
    when Category::TYPE[:GRADUATE]
      PracticeSentence::SENTENCE_MAX_LEVEL[:GRADUATE]
    end
    @user_level = ((@end_level + 1).to_f/2).round
    @sentence = PracticeSentence.find(:first, :conditions => ["level = ?", @user_level], :order => "rand()")
    @sentence_ids = [@sentence.id]
  end

  def next_sentence
    alreay_ids = params[:sentence_ids].split(",").collect { |i| i.to_i }
    @user_level = params[:current_level].to_i
    @level_change_flag = false
    if params[:true_time].to_i == 3
      @end_level = params[:end_level].empty? ? PracticeSentence::SENTENCE_MAX_LEVEL[:GRADUATE] : params[:end_level].to_i
      @user_level = ((@end_level.to_f + params[:current_level].to_f)/2).round
      @level_change_flag = true
    elsif params[:error_time].to_i == 2
      @user_level = ((1.0 + params[:current_level].to_f)/2).round
      @level_change_flag = true
    end
    @sentence = PracticeSentence.find(:first,
      :conditions => ["id not in (?) and level = ?",  alreay_ids, @user_level],
      :order => "rand()")
    @sentence_ids = alreay_ids + [@sentence.id]
    respond_to do |format|
      format.js
    end
  end

end
