module Hyalite
  ESCAPE_LOOKUP = {
    '&' => '&amp;',
    '>' => '&gt;',
    '<' => '&lt;',
    '"' => '&quot;',
    '\'' => '&#x27;',
  }

  ESCAPE_REGEX = /[&><"']/

  def self.quote_attribute_value_for_browser(text)
    "\"#{escape_text_content_for_browser(text)}\""
  end

  def self.escape_text_content_for_browser(text)
    text.gsub(ESCAPE_REGEX) {|s| ESCAPE_LOOKUP[s] }
  end
end
