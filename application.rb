require 'xmlsimple'
require 'open-uri'

class Application < Rhoconnect::Base
  class << self
    def authenticate(username,password,session)
      #Log in to web service and retrieve token
      base_url = 'http://aw.oaktree-systems.com/Service.asmx/'
      
      #Call the web service and open up the XML response
      xml_response = open(base_url + "Authenticate?userName=#{username}&password=#{password}").read
      
      # Read the response
      val = XmlSimple.xml_in(xml_response)
      token = val["content"]
      #If the token is not valid (error returned), return the value as an error message
      #Raising different error types does not appear to affect the error_code of 2
       # returned to the callback function in the params.
        raise token if token.start_with?("Error")
        
        #save the token for later use in the source adapter
        Store.put_value("username:#{username}:token",token)
        return true
    end
    
    #Add hooks for application startup here
    #Don´t forget to call super at the end!
    def initializer(path)
      super
    end
    
    #Calling super here returns rack tempfile path:
    #i.e. /var/folders/J4/J4wGJ-r6H7S313GEZ-Xx5E+++TI
    #Note: This tempfile is removed when server stops or crashes...
    #See http://rack.rubyforge.org/doc/Multipart.html for more info
    #
    # Override this by creating a copy of the file somewhere
    # and returning the path to that file ( then don´t call super!):
    #i.e /mnt/myimages/soccer.png
    
    def store_blob(object,field_name,blob)
      super #=> returns blob[:tempfile]
    end
  end
end

class SourceAdapter
  #Extend the SourceAdapter to include a login routine so it isn´t require in every source
  def call_service(call,params=nil)
    val = ""
    params = "" if params.nil?
      url = get_service + call + "?token=" + get_token + params
      #Try to call the web service and open up the XML response
      begin
        xml_response = open(url).read
      rescue Exception => e
        raise "Unable to read XML response for call: #{call}. URL: #{url}. Details: #{e.message}. Trace: #{e.backtrace}"
      end
      # Read the response
      # Must do this in a septerate step in case the response is large
      begin
        val = XmlSimple.xml_in(xml_response)
      rescue Exception => e
        raise "Error while parsing the XML response for call: #{call}. URL: #{url}. Details: #{e.message}. Trace: #{e.backtrace}"
      end
      return val
    end
      
      def get(tbl,col)
        #Read the value from the web service XML response
        begin
          value = tbl[col][0]
          #If it is an empty hash, the Web service passed back an empty string
          value = "" if value.to_s == "{}"
            return value 
          rescue
            raise "Service column '#{col}' errored out. It probably does not exist."
        end
      end
      def get_service
      return 'http://aw.oaktree-systems.com/Service.asmx/'
    end
    def get_token
      return Store.get_value("username:#{current_user.login}:token")
  end
  def is_token_valid?
    val = call_service("IsTokenValid")
    return val["content"].to_bool
  end
end

class String
  # Add to_bool to the base String object type
  def to_bool
    begin 
      return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
      return false if self == false || self.nil? || self =~ (/(false|f|no|n|0)$/i)
    rescue
    end
    raise ArgumentError.new("Invalid value for Boolean: \"#{self}\"")
  end
end
Application.initializer(ROOT_PATH)
#Support passenger smart spawning/fork mode:

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We´re in smart spawing mode.
      Store.db.client.reconnect
    else
      # We´re in conservative spawening mode. We don´t need to do anything.
    end
  end

end