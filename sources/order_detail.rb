class OrderDetail < SourceAdapter
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
      details = call_service("GetOrderDetails")
      if !details["OrderDetail"].nil?
        details["OrderDetail"].each do |od|
          detail = {}
          detail["discount"] = get(od, 'Discount')
          detail["discountpercentage"] = get(od, 'DiscountPercentage')
          detail["linetotal"] = get(od, 'LineTotal')
          detail["linetotalraw"] = get(od, 'LineTotalRaw')
          detail["orderdetailid"] = get(od, 'OrderDetailID')
                 detail["orderid"] = get(od, 'OrderID')
                 detail["productid"] = get(od, 'ProductID')
                 detail["quantity"] = get(od, 'Quantity')
          detail["unitprice"] = get(od, 'UnitPrice')
                 detail["unitpriceraw"] = get(od, 'UnitPriceRaw')
              
              #Store the value that is returned
              @result[detail["orderdetailid"]] = detail
        end
      end
  end
   
    def sync
      # Manipulate @result before it is saved, or save it 
      # yourself using the Rhoconnect::Store interface.
      # By default, super is called below which simply saves @result
      super
    end
end
    