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

class ReviewsController < ApplicationController
  before_filter :find_reviewable
  before_filter :authenticate_user!
  before_filter :authorize_review!
  
  def new
    @review = Review.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def create
    @review = @reviewable.reviews.new(params[:review])
    @review.user = current_user
    
    respond_to do |format|
      if @review.save
        flash[:notice] = 'Review Successfully Submitted'
        format.html {redirect_to controller: @reviewable.class.to_s.pluralize.underscore, action: :user_reviews}
        format.js {redirect_to controller: @reviewable.class.to_s.pluralize.underscore, action: :user_reviews}
      else
        format.html {render :new}
        format.js { render :new, :layout => false, :status => 403 }
      end
    end
  end
  
  def edit
    @review = Review.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end
  
  def update
    @review = Review.find(params[:id])
    respond_to do |format|
      if @review.update_attributes(params[:review])
        flash[:notice] = 'Review Successfully Updated'
        format.html {redirect_to controller: @reviewable.class.to_s.pluralize.underscore, action: :user_reviews}
        format.js {redirect_to controller: @reviewable.class.to_s.pluralize.underscore, action: :user_reviews}
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
  private
  
  def find_reviewable
    @reviewable_type = params[:reviewable_type]
    @reviewable_id = params[:reviewable_id]
    @klass = @reviewable_type.constantize
    @reviewable = @klass.find(@reviewable_id)
  end
  
  def authorize_review!
    authorize! :review, @reviewable
  end
  
end
