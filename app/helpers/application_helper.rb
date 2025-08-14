module ApplicationHelper
  def format_currency(amount)
    return "0원" if amount.nil? || amount.zero?
    
    # 100만원 이상은 만원 단위로 표시
    if amount >= 10000000  # 1000만원 이상
      "#{(amount / 10000).to_i}만원"
    elsif amount >= 100000  # 10만원 이상
      if amount % 10000 == 0
        "#{(amount / 10000).to_i}만원"
      else
        "#{number_with_delimiter(amount)}원"
      end
    else
      "#{number_with_delimiter(amount)}원"
    end
  end
  
  def format_currency_detailed(amount)
    return "0원" if amount.nil? || amount.zero?
    "₩#{number_with_delimiter(amount.to_i)}"
  end
  
  # .0 없는 숫자 포맷팅
  def format_number(amount)
    return "0" if amount.nil? || amount.zero?
    number_with_delimiter(amount.to_i)
  end
  
  # 가격 표시용 (.0 제거)
  def format_price(amount)
    return "0원" if amount.nil? || amount.zero?
    "#{number_with_delimiter(amount.to_i)}원"
  end
end
