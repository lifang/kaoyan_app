#encoding: utf-8
module LoginHelper
  SERVER_PATH="http://locahost:3000"

  BAIDU_API_KEY="pIQ0zFr2Qo82XQ82OoU3uAa0"
  BAIDU_API="https://openapi.baidu.com"
  BAIDU_CALLBACK=SERVER_PATH+"/pretests/respond_baidu&display=page"
  BAIDU_SERECT_KEY="oaZdGjzMlvDOjIeGGlG00bdhfYayYM4x"
  #构造get请求
  def create_get_http(url,route)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request= Net::HTTP::Get.new(route)
    back_res =http.request(request)
    return JSON back_res.body
  end
end
