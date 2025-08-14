class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { buyer: 'buyer', seller: 'seller', admin: 'admin' }

  # Associations
  has_many :vehicles, dependent: :destroy
  has_many :auctions, through: :vehicles
  has_many :bids, dependent: :destroy
  has_many :won_auctions, class_name: 'Auction', foreign_key: 'winner_id'
  has_many :payments_as_winner, class_name: 'Payment', foreign_key: 'winner_id'
  has_many :trades_as_seller, class_name: 'Trade', foreign_key: 'seller_id'
  has_many :trades_as_buyer, class_name: 'Trade', foreign_key: 'buyer_id'
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  has_one_attached :business_license

  # Validations
  validates :role, presence: true
  validates :name, presence: true
  validates :phone, presence: true, format: { with: /\A[\d\-\s\+\(\)]+\z/, message: "올바른 전화번호 형식이 아닙니다" }
  validates :company_name, presence: true, if: :seller?

  # Scopes
  scope :verified, -> { where.not(verified_at: nil) }
  scope :unverified, -> { where(verified_at: nil) }

  # Methods
  def verified?
    verified_at.present?
  end

  def full_name
    name.present? ? name : email
  end

  def can_bid?
    buyer? && verified?
  end

  def can_sell?
    seller? && verified?
  end
end
