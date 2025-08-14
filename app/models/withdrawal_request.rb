class WithdrawalRequest < ApplicationRecord
  belongs_to :seller

  # Enums
  enum :status, { 
    pending: 'pending',     # 신청됨 (승인 대기)
    approved: 'approved',   # 승인됨 (처리 완료)
    rejected: 'rejected'    # 거부됨
  }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :bank_name, presence: true
  validates :bank_account_number, presence: true
  validates :account_holder_name, presence: true
  validates :status, presence: true
  validate :amount_not_exceeds_balance, on: :create
  validate :seller_cannot_have_pending_request, on: :create

  # Callbacks
  before_create :set_requested_at
  after_update :update_seller_balance, if: :saved_change_to_status?

  # Scopes
  scope :recent, -> { order(requested_at: :desc) }
  scope :pending_requests, -> { where(status: 'pending') }

  # Methods
  def formatted_amount
    "#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def approve!(admin_memo = nil)
    transaction do
      update!(
        status: 'approved',
        admin_memo: admin_memo,
        processed_at: Time.current
      )
    end
  end

  def reject!(admin_memo)
    update!(
      status: 'rejected', 
      admin_memo: admin_memo,
      processed_at: Time.current
    )
  end

  private

  def amount_not_exceeds_balance
    return unless amount && seller

    if amount > seller.balance
      errors.add(:amount, "신청 금액이 잔액(#{seller.formatted_balance})을 초과합니다")
    end
  end

  def seller_cannot_have_pending_request
    return unless seller

    if seller.withdrawal_requests.pending.exists?
      errors.add(:base, "이미 처리 대기 중인 환전 신청이 있습니다")
    end
  end

  def set_requested_at
    self.requested_at = Time.current
  end

  def update_seller_balance
    if approved?
      seller.update!(balance: seller.balance - amount)
    end
  end
end
