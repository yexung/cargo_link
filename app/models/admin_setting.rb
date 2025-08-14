class AdminSetting < ApplicationRecord
  # Validations
  validates :setting_key, presence: true, uniqueness: true
  validates :setting_value, presence: true

  # Class methods
  def self.get(key, default_value = nil)
    setting = find_by(setting_key: key)
    setting&.setting_value || default_value
  end

  def self.set(key, value)
    setting = find_or_initialize_by(setting_key: key)
    setting.setting_value = value
    setting.save!
  end

  def self.get_commission_rate
    get('commission_rate', ENV['DEFAULT_COMMISSION_RATE'] || '5.0').to_f
  end

  def self.get_bank_info
    {
      bank_name: get('bank_name', ENV['BANK_NAME']),
      account_number: get('bank_account', ENV['BANK_ACCOUNT']),
      account_holder: get('account_holder', ENV['ACCOUNT_HOLDER'])
    }
  end
end
