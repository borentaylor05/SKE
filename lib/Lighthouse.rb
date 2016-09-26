require 'Jive2'

class Lighthouse

  def save_docs_from_file (file, client_name) 
    CSV.foreach(file, headers: true) do |row|
      doc_id = Integer(row[0]) rescue nil
      next if !doc_id
			if row[0]
        jive = Jive2.new('social')
        resp = jive.grab("/contents?filter=entityDescriptor(102,#{doc_id.to_s})")
        if resp and resp["list"]
          html = resp["list"][0]["content"]["text"]
          # puts "#{resp["list"][0]["content"]["text"]}"
          lh = LighthouseHtml.new({
            client: client_name,
            html: html
          })
          if lh.valid?
            lh.save
            puts "Saved: #{doc_id.to_s}"
          else
            puts "Error on ID #{doc_id.to_s} <------------------------"
          end
        else
          puts "Error on ID #{doc_id.to_s} <------------------------"          
        end
      end
    end
  end

end