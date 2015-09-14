class CdcController < ApplicationController

	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

end
