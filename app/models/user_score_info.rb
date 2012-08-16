#encoding: utf-8
class UserScoreInfo < ActiveRecord::Base
  belongs_to :user
  CET_PERCENT = {:WORD => 0.3, :SENTENCE => 0.4, :LINSTEN => 0.3} #单词 30%， 句子40%， 听力30%
  GRADUATE_PERCENT = {:WORD => 0.45, :SENTENCE => 0.55} #单词45%，句子55%
  LEVEL_INDEX = {:WORD => 0, :SENTENCE => 1, :LINSTEN => 2} #all_start_level中的各个等级位置
  MAX_SCORE = {:CET => 550, :GRADUATE => 75} #四六级550分，考研75分

  #更新句子的等级
  def self.update_sentence_level(category_id, user_id, final_level, index)
    info = UserScoreInfo.find_or_create_by_category_id_and_user_id(category_id, user_id)
    levels = (info.all_start_level.nil? or info.all_start_level.empty?) ? [0, 0, 0] : info.all_start_level.split(",")
    levels[index] = final_level
    info.all_start_level = levels.join(",")
    info.get_start_score(levels, index)
    info.save
  end

  #更新初始成绩
  def get_start_score(levels, index)
    if self.category_id == Category::TYPE[:GRADUATE] and index == LEVEL_INDEX[:SENTENCE]
      self.start_score = (levels[0].to_f/Word::MAX_LEVEL[:GRADUATE] * GRADUATE_PERCENT[:WORD]
        + levels[1].to_f/PracticeSentence::SENTENCE_MAX_LEVEL[:GRADUATE] * GRADUATE_PERCENT[:SENTENCE]).ceil * MAX_SCORE[:GRADUATE]
    elsif self.category_id == Category::TYPE[:CET4] and index == LEVEL_INDEX[:LINSTEN]
      self.start_score = (levels[0].to_f/Word::MAX_LEVEL[:CET4] * CET_PERCENT[:WORD]
        + levels[1].to_f/PracticeSentence::SENTENCE_MAX_LEVEL[:CET4] * CET_PERCENT[:SENTENCE]
        + levels[2].to_f/PracticeSentence::LINSTEN_MAX_LEVEL[:CET4] * CET_PERCENT[:LINSTEN]).ceil * MAX_SCORE[:CET]
    elsif self.category_id == Category::TYPE[:CET6] and index == LEVEL_INDEX[:LINSTEN]
      self.start_score = (levels[0].to_f/Word::MAX_LEVEL[:CET6] * CET_PERCENT[:WORD]
        + levels[1].to_f/PracticeSentence::SENTENCE_MAX_LEVEL[:CET6] * CET_PERCENT[:SENTENCE]
        + levels[2].to_f/PracticeSentence::LINSTEN_MAX_LEVEL[:CET6] * CET_PERCENT[:LINSTEN]).ceil * MAX_SCORE[:CET]
    end
  end
  
end
