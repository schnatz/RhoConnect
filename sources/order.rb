class Order < SourceAdapter
  def initialize(source) 
      super(source)
    end
   
    def login
      # The login routine was changed in application.rb
      raise SourceAdapterLoginException.new("1000") if !is_token_valid?
      end
    
  def query(params=nil)
    @result ={}
      
      #Query the web service using call_service method defined in application.rb
      orders = call_service("GetOrders")
      if !orders["Order"].nil?
        orders["Order"].each do |o|
          order = {}
          order["customerid"] = get(o, 'CustomerID')
          order["dateordered"] = get(o, 'DateOrdered')
          order["dateorderedraw"] = get(o, 'DateOrderedRaw')
          order["dateshipmentdue"] = get(o, 'DateShipmentDue')
          order["dateshipmentdueraw"] = get(o, 'DateShipmentDueRaw')
          order["dateshipped"] = get(o, 'DateShipped')
          order["dateshippedraw"] = get(o, 'DateShippedRaw') 
          order["orderid"] = get(o, 'OrderID')
                order["ordernumber"] = get(o, 'OrderNumber')
                order["purchaseordernumber"] = get(o, 'PurchaseOrderNumber')
                order["shipping"] = get(o, 'Shipping')
                order["shippingraw"] = get(o, 'ShippingRaw')
                order["subtotal"] = get(o, 'SubTotal') 
          order["subtotalraw"] = get(o, 'SubTotalRaw')
                order["taxamount"] = get(o, 'TaxAmount')
                order["taxamountraw"] = get(o, 'TaxAmountRaw')
                order["totaldue"] = get(o, 'TotalDue')
                order["totaldueraw"] = get(o, 'TotalDueRaw')
               
              #Store the value that is returned
              @result[order["orderid"]] = order
        end
      end
  end
   
    def sync
      # Manipulate @result before it is saved, or save it 
      # yourself using the Rhoconnect::Store interface.
      # By default, super is called below which simply saves @result
      super
    end
    def create(create_hash)
      c = create_hash
      if !c["product"].nil?
        val =
       call_service("SellProduct","&customerID=#{c["customer"]}&productID=#{c["product"]}&quantity=#{c["quantity"]}&purchaseOrderNo=#{c["purchaseordernumber"]}&discountPercent=#{c["discount"]}")
        if !val["content"].start_with?("ERROR")
          items = val["content"].split("/")
            items.each do |item|
              parts = item.split(":")
              #only interested in the orderID
              return parts[1].strip if parts[0] == "OrderID"
            end
        end
      end
end
end