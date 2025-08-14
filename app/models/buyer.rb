class Buyer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 관계 설정
  has_many :bids, dependent: :destroy
  has_many :auctions, through: :bids
  has_many :payments, dependent: :destroy
  has_many :trades, foreign_key: 'buyer_id', dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id', dependent: :destroy

  # 유효성 검사
  validates :name, presence: true
  validates :phone, presence: true
  validates :country, presence: true

  # 스코프
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  # 메서드
  def approved?
    approved
  end

  def can_bid?
    approved?
  end

  def full_name
    name
  end
end
