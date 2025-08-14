class Vehicle < ApplicationRecord
  belongs_to :seller

  # Enums
  enum :status, { pending: 'pending', active: 'active', sold: 'sold', rejected: 'rejected' }
  enum :fuel_type, { gasoline: 'gasoline', diesel: 'diesel', hybrid: 'hybrid', electric: 'electric' }
  enum :transmission, { manual: 'manual', automatic: 'automatic', cvt: 'cvt' }

  # Associations
  has_many :auctions, dependent: :destroy
  has_many :trades, dependent: :destroy
  has_many_attached :images

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true, 
            numericality: { greater_than: 1900, less_than_or_equal_to: Date.current.year + 1 }
  validates :mileage, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :starting_price, presence: true, numericality: { greater_than: 0 }
  validates :fuel_type, presence: true
  validates :transmission, presence: true

  # Scopes
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :by_fuel_type, ->(fuel_type) { where(fuel_type: fuel_type) }
  scope :by_transmission, ->(transmission) { where(transmission: transmission) }
  scope :by_year_range, ->(min_year, max_year) { where(year: min_year..max_year) }
  scope :by_price_range, ->(min_price, max_price) { where(starting_price: min_price..max_price) }
  scope :recent, -> { order(created_at: :desc) }
  scope :includes_for_select, -> { select(:id, :title, :brand, :model, :year, :starting_price) }

  # Methods
  def display_title
    "#{year}년 #{brand} #{model} - #{title}"
  end

  def formatted_price
    "₩#{starting_price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def can_create_auction?
    active? && auctions.active.empty?
  end

  def has_active_auction?
    auctions.where(status: ['active', 'upcoming']).exists?
  end

  def current_auction
    auctions.where(status: ['active', 'upcoming']).first
  end

  def can_be_auctioned?
    active? && !has_active_auction?
  end
end
