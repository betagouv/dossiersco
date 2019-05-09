# frozen_string_literal: true

PrawnRails.config do |config|
  config.page_layout = :portrait
  config.page_size   = "A4"
  config.skip_page_creation = false
end

Prawn::Font::AFM.hide_m17n_warning = true
