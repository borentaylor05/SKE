require 'Lighthouse'

task :save_doc_html_from_csv => :environment	do
  lh = Lighthouse.new()
  lh.save_docs_from_file('hyundai-lh-docs.csv', 'hyundai')
end