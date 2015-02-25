class AddressBookController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :access_check
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	def get_all
		if AddressBookEntry.count > 0
			respond({ status: 0 , entries: AddressBookEntry.select(:id, :ProgramDescription, :AlternateTopicName) })
		else
			respond({ status: 1, error: "No Address Book Entries in Database" })
		end
	end

	def get_entry
		if AddressBookEntry.exists?(id: params[:id])
			respond({ status: 0, entry: AddressBookEntry.find(params[:id]) })
		else
			respond({ status: 1, error: "No entry with id #{params[:id]} found." })
		end
	end

end
