class Payment < ApplicationRecord
  belongs_to :auction
  belongs_to :winner, class_name: 'Buyer'
  belongs_to :buyer, class_name: 'Buyer', foreign_key: 'winner_id'

  # Enums
  enum :status, { pending: 'pending', reported: 'reported', confirmed: 'confirmed', rejected: 'rejected' }

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :vehicle_price, presence: true, numericality: { greater_than: 0 }
  validates :commission_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :commission_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 100 }
  validates :status, presence: true
  validates :bank_name, presence: true, if: :deposit_reported?
  validates :account_number, presence: true, if: :deposit_reported?
  validates :depositor_name, presence: true, if: :deposit_reported?
  validates :deposit_datetime, presence: true, if: :deposit_reported?

  # Callbacks
  before_create :calculate_amounts
  after_update :notify_seller_on_confirmation

  # Scopes
  scope :pending_confirmation, -> { where(status: ['pending', 'reported']) }
  scope :confirmed, -> { where(status: 'confirmed') }

  # Methods
  def seller_amount
    # 판매자는 차량 가격 전액을 받음 (수수료는 구매자가 부담)
    vehicle_price
  end

  def formatted_total_amount
    "#{total_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def formatted_seller_amount
    "#{seller_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def formatted_commission_amount
    "#{commission_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def formatted_amount
    "₩#{total_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def deposit_reported?
    bank_name.present? || account_number.present? || depositor_name.present? || deposit_datetime.present?
  end

  def vehicle
    auction.vehicle
  end

  def seller
    auction.seller
  end

  def confirm_payment!(admin_memo = nil)
    transaction do
      update!(
        status: 'confirmed',
        admin_memo: admin_memo
      )
      
      auction.update!(status: 'paid')
      
      # 판매자 잔고에 판매 수익 추가
      seller.add_balance!(vehicle_price)
    end
  end

  def reject_payment!(admin_memo)
    update!(
      status: 'rejected',
      admin_memo: admin_memo
    )
  end

  private

  def calculate_amounts
    return unless auction

    self.vehicle_price = auction.current_price
    self.commission_rate ||= AdminSetting.get_commission_rate
    self.commission_amount = vehicle_price * (commission_rate / 100.0)
    self.total_amount = vehicle_price + commission_amount
  end

  def notify_seller_on_confirmation
    if saved_change_to_status? && confirmed?
      PaymentMailer.seller_payment_confirmed(self).deliver_later
    end
  end
end
