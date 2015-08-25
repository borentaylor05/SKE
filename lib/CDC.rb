require 'Jive2'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class CDC

	def initialize(instance)
		@jive = Jive2.new(instance)
	end

	def import_address_book(file)
		CSV.foreach(file, headers: true) do |row|
			row[0] = row[0].strip if row[0] # row[0] is Program Description
			entry = AddressBookEntry.find_by(ProgramDescription: row[0])
			if entry
				entry.update_attributes(row.to_hash)
			else
				ab = AddressBookEntry.create! row.to_hash
			end
		end
	end

	def import_a_to_z(file)
		CSV.foreach(file, headers: true) do |row|
			row[0] = row[0].strip if row[0] # row[0] is Topic
			entry = AToZEntry.find_by(topic: row[0].upcase)
			pr = row[6].strip if row[6]
			spanish = row[8].strip if row[8]
			if entry
				entry.update_attributes(
					aka: row[1],
					owner: row[2],
					scope: row[3],
					notes: row[4],
					program_flow: row[5],
					pr: pr == "YES" ? true : false,
					cdc_link: row[7],
					spanish: row[8] == "Y" ? true : false
				)
			else
				AToZEntry.create!(
					topic: row[0].upcase,
					aka: row[1],
					owner: row[2],
					scope: row[3],
					notes: row[4],
					program_flow: row[5],
					pr: pr == "YES" ? true : false,
					cdc_link: row[7],
					spanish: row[8] == "Y" ? true : false
				)
			end
		end
	end

	def import_gamification(file)
		errors = []
		CSV.foreach(file.path, headers: true) do |row|
			row.each do |r|
				if r == "---"
					r = nil
				end
			end
			if row.count == 5
				user = User.find_by(employee_id: row[0])
				Rails.logger.info(row[0])
				if user 
					if !user.update_attributes(comp_score: row[2], rank: row[3], tier: row[4])
						Rails.logger.info("Error updating.")
						errors.push row[0]
					end
				else
					Rails.logger.info "User #{row[0]} not found."
					errors.push row[0]
				end
			else
				Rails.logger.info("CSV wrong format")
				errors.push "Wrong format at #{row[0]}!"
				return errors
			end
		end
		return errors
	end

	def parse_apg(title, filename)
		doc = CdcApgDocument.create(client: Client.find_by(name: "cdc"), title: title)	
		page_sections = []	
		page = Nokogiri::HTML(open(filename))   
		page.css('h1').each do |h|
			section = { main_header: h.text, subheaders: [ ] }
			next_el_h1 = h.next_element
			while next_el_h1 and next_el_h1.name != 'h1'
				if next_el_h1.name == 'h2' 
					h2 = next_el_h1					
					if h2.text.length < 3 
						next_el_h1 = next_el_h1.next_element
						next
					end
					puts h2.text
					subheader = { name: h2.text, paragraphs: [], notes: [] }
					next_el_h2 = h2.next_element
					while next_el_h2 and next_el_h2.name != 'h2'
						subheader[:paragraphs].push(next_el_h2.to_s) if next_el_h2.text.length > 1						
						next_el_h2 = next_el_h2.next_element
					end
					section[:subheaders].push(subheader)					
				end
				next_el_h1 = next_el_h1.next_element
			end
			page_sections.push(section)
		end
		page_sections.each do |s|
			newSection = CdcApgSection.create!(title: s[:main_header], cdc_apg_document: doc)
			s[:subheaders].each do |sub|
				newSub = CdcApgSubheader.create!(title: sub[:name], cdc_apg_section: newSection)
				sub[:paragraphs].each do |p|
					newPar = CdcApgParagraph.create!(text: p, cdc_apg_subheader: newSub)
				end
				sub[:notes].each do |n|
					newNote = CdcApgNote.create!(text: n, cdc_apg_subheader: newSub)
				end
			end
		end
	end

end