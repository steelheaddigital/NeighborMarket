class InPersonSetting
  acts_as_singleton
  extend ActiveModel::Model
  extend ActiveModel::Assocations
  
  belongs_to :payment_processor_setting

  def payment_processor_setting_id
    1
  end

  def id
    1
  end

  def in_person_payments_enabled
    true
  end

  def persisted?
    id == 1
  end
end
