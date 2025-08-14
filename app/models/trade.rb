class Trade < ApplicationRecord
  belongs_to :seller
  belongs_to :buyer, optional: true

  # Enums
  enum :status, { active: 'active', completed: 'completed' }

  # Associations
  has_many :messages, dependent: :destroy
  has_many_attached :images

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :description, presence: true
  validates :trade_type, presence: true
  validates :location, presence: true
  validates :contact_info, presence: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { greater_than: 1990, less_than_or_equal_to: Date.current.year + 1 }
  validates :mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fuel_type, presence: true
  validates :transmission, presence: true

  # Scopes
  scope :available, -> { where(status: 'active') }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def formatted_price
    "₩#{price.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def complete_trade!
    return false unless active?
    
    update!(status: 'completed')
  end

  def seller_name
    seller&.name || '알 수 없음'
  end

  def buyer_name
    buyer&.name || '구매자 없음'
  end

  def display_title
    "#{year}년 #{brand} #{model} - #{title}"
  end
  
  def fuel_type_korean
    case fuel_type
    when 'gasoline' then '가솔린'
    when 'diesel' then '디젤'
    when 'hybrid' then '하이브리드'
    when 'electric' then '전기'
    when 'lpg' then 'LPG'
    else fuel_type
    end
  end
  
  def transmission_korean
    case transmission
    when 'manual' then '수동'
    when 'automatic' then '자동'
    when 'cvt' then 'CVT'
    else transmission
    end
  end
end
