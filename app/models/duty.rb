class Duty < ActiveRecord::Base
  has_many :preferences, dependent: :destroy
  has_and_belongs_to_many :users
  belongs_to :rotum

  attr_accessible :day, :ends, :starts, :user_id, :user_ids, :rotum_id

  def to_s
    day_str
  end

  def day_str
    day.strftime('%A %d')
  end

  def starts_str
    starts.strftime('%H:%M')
  end

  def ends_str
    ends.strftime('%H:%M')
  end

  def times_str
    "#{starts_str} - #{ends_str}"
  end

  def saturday?
    day.saturday?
  end

  def sunday?
    day.sunday?
  end

  def weight
    ((starts - ends) / 1.hour).round
  end

  def preference_count
    preferences.size
  end

  def wday
    day.wday
  end

  def conflicts
    users.joins(:preferences).where(preferences: { duty_id: id })
  end

  def swap(swapped_out, swapped_in)
    preference = preferences.where(user_id: swapped_in.id)
    preference.destroy if preference.present?
    users.delete(swapped_out)
    users << swapped_in
  end

  def take(user)
    swap(conflicts.first, user)
  end

  def user_names
    users.map { |user| user.name }.join(", ")
  end

  def preferences_user_names
    preferences.map { |preference| preference.user_name }.join(", ")
  end
end
