class Bid < ApplicationRecord
  belongs_to :auction
  belongs_to :buyer

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :bid_time, presence: true
  validate :buyer_can_bid
  validate :amount_meets_minimum
  validate :auction_is_active

  # Callbacks
  before_validation :set_bid_time

  # Scopes
  scope :recent, -> { order(bid_time: :desc) }
  scope :by_auction, ->(auction) { where(auction: auction) }

  # Methods
  def formatted_amount
    "₩#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def is_winning_bid?
    auction.highest_bid == self
  end

  private

  def set_bid_time
    self.bid_time ||= Time.current
  end

  def buyer_can_bid
    unless buyer&.approved?
      errors.add(:buyer, "승인된 구매자만 입찰할 수 있습니다")
    end
  end

  def amount_meets_minimum
    return unless auction && amount

    min_amount = auction.current_price + auction.increment_amount
    if amount < min_amount
      errors.add(:amount, "최소 입찰 금액은 ₩#{min_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}입니다")
    end
  end

  def auction_is_active
    unless auction&.active?
      errors.add(:auction, "활성 상태인 경매에만 입찰할 수 있습니다")
    end
  end
end
