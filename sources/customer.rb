class Customer < SourceAdapter
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
      customers = call_service("GetCustomers")
      if !customers["Customer"].nil?
        customers["Customer"].each do |c|
          customer = {}
            customer["companyname"] = get(c, 'CompanyName')
            customer["customerid"] = get(c, 'CustomerID')
            customer["email"] = get(c, 'Email')
          customer["addressline1"] = get(c, 'AddressLine1')
            customer["addressline2"] = get(c, 'AddressLine2')
            customer["city"] = get(c, 'City')  
            customer["country"] = get(c, 'Country')
            customer["firstname"] = get(c, 'FirstName')
            customer["lastname"] = get(c, 'LastName')
            customer["middlename"] = get(c, 'MiddleName')
            customer["namesuffix"] = get(c, 'NameSuffix')
            customer["phone"] = get(c, 'Phone')
            customer["photo"] = get(c, 'Photo')
            customer["postalcode"] = get(c, 'PostalCode')
            customer["salutation"] = get(c, 'Salutation')
            customer["state"] = get(c, 'State')                        
              #Store the value that is returned
              @result[customer["customerid"]] = customer
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
   
    def update(update_hash)
c = update_hash
if !c["phone"].nil?
  val = call_service("SetCustomerPhoneNumber","&customerID=#{c["id"]}&phoneNumber=#{URI::encode(c["phone"])}")
  return val ["content"].to_bool
    end
    end
    def delete(delete_hash)
      # TODO: write some code here if applicable
      # be sure to have a hash key and value for "object"
      # for now, we'll say that its OK to not have a delete operation
      # raise "Please provide some code to delete a single object in the backend application using the object_id"
    end
   
    def logoff
      # TODO: Logout from the data source if necessary
    end
  end