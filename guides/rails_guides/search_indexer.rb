require 'redcarpet'
require 'redcarpet/render_strip'

module RailsGuides
  class SearchIndexer
    GUIDES_RE = /\.(?:erb|md)\z/

    def initialize
      @source_dir = "#{File.expand_path("..", __dir__)}/source"
    end

    def index
      guides = Dir.entries(@source_dir).grep(GUIDES_RE)
      guides.each do |guide|
        guide_path = File.join(@source_dir, guide)
        guide_content = File.read(guide_path)
        raw_header, _, raw_body = extract_raw_header_and_body(guide_content)
        guide_text = markdown_to_text(raw_body || guide_content)
        puts "Header: #{raw_header}", '---------------', "Body: #{guide_text}"
      end
    end

    private
      def extract_raw_header_and_body(raw_body)
        if /^\-{40,}$/.match?(raw_body)
          raw_body.partition(/^\-{40,}$/).map(&:strip)
        end
      end

      def markdown_to_text(mardown)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
        markdown.render(mardown)
      end
  end
end

RailsGuides::SearchIndexer.new.index