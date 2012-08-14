# encoding: utf-8
class Category < ActiveRecord::Base
  has_many :practice_sentences
  
  TYPE = {:CET4 => 2, :CET6 => 3, :GRADUATE => 4}
  FLAG = {2 => 'CET4', 3 => 'CET6', 4 => 'GRADUATE'}
end
