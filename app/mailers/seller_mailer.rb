class SellerMailer < BaseMailer

  def seller_approved_mail(user)
    @site_settings = SiteSetting.first
    mail(:to => user.email, :subject => "Your #{@site_settings.site_name} Seller Account Is Approved" )
  end
  
  def new_purchase_mail(seller, order)
    @buyer = order.user
    @cart_items = order.cart_items.joins(:inventory_item).where("inventory_items.user_id = ?", seller.id)
    site_settings = SiteSetting.first
    mail( :to => seller.email, 
          :subject => "A purchase of your product has been made at #{site_settings.site_name}")
  end
  
  def order_cycle_end_mail(seller, order_cycle)

    @site_settings = SiteSetting.first
    @seller = seller
    @order_cycle = order_cycle
    @orders = Order.joins(:cart_items => :inventory_item)
                   .select('orders.id, orders.user_id')
                   .where(:inventory_items => {:user_id => seller.id}, :orders => {:order_cycle_id => order_cycle.id})
                   .group('orders.id, orders.user_id')
    @inventory_items = InventoryItem.joins(:cart_items => :order)
                                .where('inventory_items.user_id = ? AND orders.order_cycle_id = ?', seller.id, order_cycle.id)
                                .select('inventory_items.id, inventory_items.name, inventory_items.price_unit, sum(cart_items.quantity)')
                                .group('inventory_items.id, inventory_items.name, inventory_items.price_unit')
                   
    packing_list = render_to_string('seller/packing_list.pdf', :type => :prawn)
    pick_list = render_to_string('seller/pick_list.pdf', :type => :prawn)
    attachments['packing_list.pdf'] = packing_list
    attachments['pick_list.pdf'] = pick_list
    mail( :to => seller.email, 
          :subject => "The current order cycle has ended at #{@site_settings.site_name}")
  end
  
end
