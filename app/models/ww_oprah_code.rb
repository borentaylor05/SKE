class WwOprahCode < ActiveRecord::Base

  def self.import(file)
    file = RubyXL::Parser.parse(file.path)
    sheet = file[0]
    sheet.each do |row|
      row && row.cells.each do |cell| 
        if cell && cell.value
          WwOprahCode.create({
            code: cell.value
          })
        end
      end
    end
  end

end
