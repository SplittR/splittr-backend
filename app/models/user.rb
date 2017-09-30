class User < ApplicationRecord
  has_many :created_groups, foreign_key: :creator_id, class_name: "Group"
  has_many :memberships
  has_many :groups, through: :memberships
  has_many :expenses, through: :memberships

  has_secure_password

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  # virtual attributes
  def full_name
    first_name + " " + last_name
  end

  # debt calculation methods
  def total_group_spend(group_id)
    group = Group.find_by(id: group_id)
    user_expenses = group.expenses.select{|expense| expense.user == self}
    user_expenses.inject(0){|sum, expense| sum + expense.amount}
  end

  def owes_group?(group_id)
    group = Group.find_by(id: group_id)
    self.total_group_spend(group.id) < group.member_split
  end

  def owed_by_group?(group_id)
    group = Group.find_by(id: group_id)
    self.total_group_spend(group.id) > group.member_split
  end

  def amount_owed_by_group(group_id)
    group = Group.find_by(id: group_id)
    if self.owed_by_group?(group_id)
      self.total_group_spend(group_id) - group.member_split
    else
      return nil
    end
  end

  def amount_owes_group(group_id)
    group = Group.find_by(id: group_id)
    if self.owes_group?(group_id)
      group.member_split - self.total_group_spend(group_id)
    else
      return nil
    end
  end

  # json object rendering methods
  def user_data
    { user: self,
      user_groups: self.groups
    }
  end

end
