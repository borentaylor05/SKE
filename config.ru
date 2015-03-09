# This file is used by Rack-based servers to start the application.
require 'rack/cors'
use Rack::Cors do
	allow do
		origins 'localhost:3000', '127.0.0.1:3000', '127.0.0.1:8080', '127.0.0.1:8090', 'localhost:8080', 'localhost:8090',
	    	'social.teletech.com', 'lit-inlet-2632.herokuapp.com', 'jivedemo-teletech-gtm-alliances.jiveon.com'

		resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
	end

	allow do
		origins '*'

		resource '/maintainers/*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
		resource '/fx/tickets', :headers => :any, :methods => [:get, :post, :put, :delete, :options]

	end

end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
