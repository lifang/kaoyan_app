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

  #取到默认开始的词库、句子跟听力
  def get_start_level
    all_start_level =  self.all_start_level.split(",")
    words = Word.find(:all, :select => "id", :conditions => ["category_id = ? and level = ?",
        self.category_id, all_start_level[0]])
    word_list = words.collect { |w| w.id }
    practice_sentences = PracticeSentence.find(:all, :select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:SENTENCE], all_start_level[1]])
    sentence_list = practice_sentences.collect { |s| s.id }
    listens = PracticeSentence.find(:all, :select => "id",
      :conditions => ["category_id = ? and types = ? and level = ?",
        self.category_id, PracticeSentence::TYPES[:LINSTEN], all_start_level[2]])
    listen_list = listens.collect { |l| l.id }
    return {:word => word_list, :practice_sentences => sentence_list, :listens => listen_list, :levels => all_start_level}
  end
  
end
