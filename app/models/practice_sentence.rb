class PracticeSentence < ActiveRecord::Base
  belongs_to :category
  TYPES = {:SENTENCE => 0, :LINSTEN => 1, :TRANSLATE => 2, :DICTATION => 3} #0 句子  1 听力  2 翻译  3 听写
  SENTENCE_MAX_LEVEL = {:CET4 => 10, :CET6 => 15, :GRADUATE => 10 }#20

  def self.max_level(category_id)
    return case category_id
    when Category::TYPE[:CET4]
      PracticeSentence::SENTENCE_MAX_LEVEL[:CET4]
    when Category::TYPE[:CET6]
      PracticeSentence::SENTENCE_MAX_LEVEL[:CET6]
    when Category::TYPE[:GRADUATE]
      PracticeSentence::SENTENCE_MAX_LEVEL[:GRADUATE]
    end
  end
end
