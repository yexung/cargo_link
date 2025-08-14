class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 관계 설정
  has_many :vehicles, dependent: :destroy
  has_many :auctions, through: :vehicles
  has_many :trades, foreign_key: 'seller_id', dependent: :destroy
  has_many :withdrawal_requests, dependent: :destroy

  # 직접적인 경매 관계 (편의 메서드)
  def my_auctions
    Auction.joins(:vehicle).where(vehicles: { seller_id: id })
  end

  # 유효성 검사
  validates :name, presence: true
  validates :phone, presence: true

  # 스코프
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  # 메서드
  def approved?
    approved
  end

  def full_name
    name
  end

  # 잔고 관련 메서드
  def formatted_balance
    "#{balance.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def add_balance!(amount)
    update!(balance: balance + amount)
  end

  def subtract_balance!(amount)
    if balance >= amount
      update!(balance: balance - amount)
    else
      raise "잔액이 부족합니다"
    end
  end

  # 환전 가능 여부 확인
  def can_request_withdrawal?
    balance > 0 && !withdrawal_requests.pending.exists?
  end

  # 총 수익 계산 (확정된 결제만)
  def total_earnings
    Payment.joins(auction: :vehicle)
           .where(vehicles: { seller_id: id }, status: 'confirmed')
           .sum(:vehicle_price)
  end

  # 환전된 총 금액
  def total_withdrawn
    withdrawal_requests.approved.sum(:amount)
  end
end
