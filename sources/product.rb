class Product < SourceAdapter
  def initialize(source) 
      super(source)
    end
   
    def login
      # The login routine was changed in application.rb
    raise SourceAdapterLoginException.new("1000") if !is_token_valid?
    end
    
    #Create a method to ensure curreny is formatted correctly
    
    def format_currency( value, pre_symbol='$', thousands=',' )
      "#{pre_symbol}#{
      ("%.2f" % value).gsub(
      /(\d)(?=(?:\d{3})+(?:$|\.))/,
      "\\1#{thousands}")}"
    end
      
  #Create a method that can be called for each Parent category
    # This prevents having to duplicate this code for each method
      
    def handle_product(p)
      product = {}
       product["categoryid"] = get(p, 'CategoryID')   
      product["color"] = get(p, 'Color')
      product["datesellend"] = get(p, 'DateSellEnd')
      product["datesellendraw"] = get(p, 'DateSellEndRaw')
      product["datesellstart"] = get(p, 'DateSellStart')
      product["datesellstartraw"] = get(p, 'DateSellStartRaw')
      product["listprice"] = get(p, 'ListPrice')
      product["listpriceraw"] = get(p, 'ListPriceRaw')
      product["modelid"] = get(p, 'ModelID')
      product["name"] = get(p, 'Name')
      product["photo"] = get(p, 'Photo')
      product["productid"] = get(p, 'ProductID')
      product["productnumber"] = get(p, 'ProductNumber')
      product["size"] = get(p, 'Size')
      product["standardcost"] = get(p, 'StandardCost')
      product["standardcostraw"] = get(p, 'StandardCostRaw')
        #Add a custom field so the reps can see the profit per product
        product["profit"] = format_currency(product["listprice"].to_f - product["standardcost"].to_f)
          product["profitraw"] = product["listprice"].to_f - product["standardcost"].to_f
            
      #Look up taxes and shipping costs
      #Value returned looks like the following line:
      #SubTotal: $34.99/Tax: $2.80/Shipping:$0.87/Total: $38.66
            
            pricing = 
            call_service("GetPricing", "&productID=#{product["productid"]}&quantity=1&discountPercent=0")
            if !pricing["content"].start_with?("ERROR")
              items = pricing["content"].split("/")
                items.each do |item|
                  parts = item.split(":")
                  
                  #Only interested in the Tax and Shipping items
                  
                  if parts[0] == "Tax" || parts[0] == "Shipping"
                    product["tax"] = parts[1].strip
                    product["shipping"] = parts[1].strip  
                      
                      amount = parts[1].split("$")
                      product["taxraw"] = amount[1]
                        
                   amount = parts[1].split("$")
                   product["shippingraw"] = amount[1]    
                  end
                end
            end
              return product
end

  def query(params=nil)
    @result ={}
      
      #Query the web service - info on the first parent category
      products = call_service("GetProductAccessories")
      if !products["Product"].nil?
        products["Product"].each do |p|
          product = handle_product(p)
          
          #Store the value that is returned

              @result[product["productid"]] = product
        end
      end
    #Query the web service
      products = call_service("GetProductBikes")
      if !products["Product"].nil?
        products["Product"].each do |p|
          product = handle_product(p)
       
        #Store the value that is returned

              @result[product["productid"]] = product
        end
      end
      
#Query the web service
      products = call_service("GetProductClothing")
      if !products["Product"].nil?
        products["Product"].each do |p|
          product = handle_product(p)
       
        #Store the value that is returned

              @result[product["productid"]] = product
        end
      end
      
#Query the web service
      products = call_service("GetProductComponents")
      if !products["Product"].nil?
        products["Product"].each do |p|
          product = handle_product(p)
       
        #Store the value that is returned

              @result[product["productid"]] = product
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
      # TODO: Create a new record in your backend data source
      raise "Please provide some code to create a single record in the backend data source using the create_hash"
    end
   
   
    def logoff
      # TODO: Logout from the data source if necessary
    end
  end