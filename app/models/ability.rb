#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

class Ability
  include CanCan::Ability

  def initialize(user, session)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    user ||= User.new # guest user (not logged in)

    if user.manager?
      can :manage, :all
    end
    
    if user.approved_seller?
      can :manage, InventoryItem, :user_id => user.id
      can :create, InventoryItemChangeRequest
    end
    
    if user.buyer?
      can :update, Order, :user_id => user.id
      can :create, Order
      can :finish, Order
      can :create, OrderChangeRequest
    end
    
    if user
      #Anyone can delete a cart_item that is in their session
      if session[:cart_id]
        cart = Cart.find(session[:cart_id])
        can :destroy, CartItem if cart.cart_items.where("cart_id = ? AND order_id IS NULL", cart.id).count > 0
        can :manage, Cart if cart
      end
      can [:show,:contact, :contact_form], User do |u|
        u.approved_seller?
      end 
    end
  end
end
