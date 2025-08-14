class Message < ApplicationRecord
  # 다형성 관계로 sender와 receiver를 처리 (Seller, Buyer, AdminUser 모두 가능)
  belongs_to :sender, polymorphic: true
  belongs_to :receiver, polymorphic: true
  belongs_to :trade

  # Validations
  validates :content, presence: true
  validates :sent_at, presence: true

  # Callbacks
  before_validation :set_sent_at

  # Scopes
  scope :recent, -> { order(sent_at: :desc) }
  scope :chronological, -> { order(sent_at: :asc) }
  scope :for_trade, ->(trade) { where(trade: trade) }

  # Methods
  def sender_name
    sender&.name || '알 수 없음'
  end

  def receiver_name
    receiver&.name || '알 수 없음'
  end

  def sender_type_name
    case sender_type
    when 'Seller'
      '판매자'
    when 'Buyer'
      '구매자'
    when 'AdminUser'
      '관리자'
    else
      '사용자'
    end
  end

  def formatted_sent_at
    sent_at.strftime('%Y-%m-%d %H:%M')
  end

  def sent_by?(user)
    sender == user
  end

  private

  def set_sent_at
    self.sent_at ||= Time.current
  end
end
