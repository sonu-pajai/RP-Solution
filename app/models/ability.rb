class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.admin?
      can :manage, :all
    elsif user.approver?
      can :read, ReportingEntity
      can :read, Relationship
      can :read, ReportingUnit
      can :read, Transaction
      can :read, Period
    elsif user.checker?
      can :read, ReportingEntity
      can :read, Relationship
      can :read, ReportingUnit
      can :read, Transaction
      can :read, Period
    elsif user.maker?
      can [:read, :create, :update], ReportingEntity
      can [:read, :create, :update], Relationship
      can [:read, :create, :update], ReportingUnit
      can [:read, :create, :update], Transaction
      can [:read, :create, :update], Period
    end
  end
end
