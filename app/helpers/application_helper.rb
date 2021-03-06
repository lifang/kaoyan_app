module ApplicationHelper

  REDIRECT_URL="http://localhost:3001/plans/show_result"
  BACK_PATH_URL = "http://manage.gankao.co"

  #更新句子的等级
  def update_sentence_level(category_id, final_level, index)
    levels = (cookies["#{Category::FLAG[category_id]}"].nil? or cookies["#{Category::FLAG[category_id]}"].empty?) ?
      [0, 0, 0, 0] : cookies["#{Category::FLAG[category_id]}"].split(",")
    levels[index] = final_level
    levels[-1] = UserScoreInfo.get_start_score(levels, index, category_id)
    cookies["#{Category::FLAG[category_id]}"] = levels.join(",") if cookies["#{Category::FLAG[category_id]}"]  
  end
  
end
