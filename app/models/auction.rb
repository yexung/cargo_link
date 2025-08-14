class Auction < ApplicationRecord
  belongs_to :vehicle
  belongs_to :winner, class_name: 'Buyer', optional: true

  # Enums
  enum :status, { upcoming: 'upcoming', active: 'active', ended: 'ended', paid: 'paid', completed: 'completed' }

  # Associations
  has_many :bids, dependent: :destroy
  has_one :payment, dependent: :destroy

  # Delegate seller from vehicle
  delegate :seller, to: :vehicle

  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :current_price, presence: true, numericality: { greater_than: 0 }
  validates :increment_amount, presence: true, numericality: { greater_than: 0 }
  validates :reserve_price, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validate :end_time_after_start_time
  # validate :start_time_in_future, on: :create  # 임시로 주석처리

  # Callbacks
  before_save :update_status_based_on_time
  after_create :set_initial_current_price
  before_validation :set_default_increment_amount, on: :create

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :ended, -> { where(status: 'ended') }
  scope :current, -> { where('start_time <= ? AND end_time >= ?', Time.current, Time.current) }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }

  # Methods
  def time_remaining
    return 0 if ended?
    return 0 if end_time < Time.current
    
    (end_time - Time.current).to_i
  end

  def time_remaining_text
    remaining = time_remaining
    return "종료됨" if remaining <= 0
    
    if remaining > 86400 # 1 day
      "#{remaining / 86400}일 #{(remaining % 86400) / 3600}시간"
    elsif remaining > 3600 # 1 hour
      "#{remaining / 3600}시간 #{(remaining % 3600) / 60}분"
    else
      "#{remaining / 60}분 #{remaining % 60}초"
    end
  end

  def highest_bid
    bids.order(amount: :desc).first
  end

  def can_bid?(user, amount)
    return false unless active?
    return false unless user&.can_bid?
    return false if amount <= current_price
    return false if amount < (current_price + increment_amount)
    
    true
  end

  def place_bid!(user, amount)
    return false unless can_bid?(user, amount)
    
    transaction do
      bid = bids.create!(
        user: user,
        amount: amount,
        bid_time: Time.current
      )
      
      update!(current_price: amount)
      bid
    end
  end

  def end_auction!
    return false unless active?
    
    transaction do
      update!(status: 'ended')
      
      if highest_bid
        update!(winner: highest_bid.buyer)
        vehicle.update!(status: 'sold')
        
        # Payment 자동 생성
        create_payment_for_winner!
        
        # AuctionMailer.winner_notification(self).deliver_later
      end
    end
  end

  def seller
    vehicle.seller
  end

  # 만료된 경매들을 자동으로 종료시키는 클래스 메서드
  def self.end_expired_auctions!
    expired_auctions = where(status: 'active').where('end_time < ?', Time.current)
    
    expired_auctions.each do |auction|
      Rails.logger.info "Auto-ending expired auction #{auction.id}"
      auction.end_auction!
    end
    
    expired_auctions.count
  end

  def current_status
    return status if status == 'ended' || status == 'paid' || status == 'completed'
    
    now = Time.current
    
    if start_time > now
      'upcoming'
    elsif end_time > now
      'active'
    else
      'ended'
    end
  end

  def currently_active?
    current_status == 'active'
  end

  def currently_ended?
    current_status == 'ended'
  end

  def currently_upcoming?
    current_status == 'upcoming'
  end

  def create_payment_for_winner!
    return unless winner && current_price > 0
    
    commission_rate = AdminSetting.get_commission_rate
    vehicle_price = current_price
    commission_amount = vehicle_price * (commission_rate / 100.0)
    total_amount = vehicle_price + commission_amount
    
    Payment.create!(
      auction: self,
      winner: winner,
      vehicle_price: vehicle_price,
      commission_rate: commission_rate,
      commission_amount: commission_amount,
      total_amount: total_amount
    )
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, "시작 시간보다 늦어야 합니다")
    end
  end

  def start_time_in_future
    return unless start_time
    
    if start_time <= Time.current
      errors.add(:start_time, "미래 시간이어야 합니다")
    end
  end

  def update_status_based_on_time
    # 수동으로 종료된 경매는 상태를 변경하지 않음
    return if ended?
    
    now = Time.current
    
    if start_time > now
      self.status = 'upcoming'
    elsif end_time > now
      self.status = 'active'
    elsif status == 'active'
      self.status = 'ended'
    end
  end

  def set_initial_current_price
    self.current_price = vehicle.starting_price if current_price.blank?
  end

  def set_default_increment_amount
    self.increment_amount = (reserve_price * 0.05).round if increment_amount.blank? && reserve_price.present?
  end
end
