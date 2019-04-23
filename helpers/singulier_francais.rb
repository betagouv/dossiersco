# frozen_string_literal: true

require 'active_support/inflector'
class String
  def singularize(locale = :fr)
    ActiveSupport::Inflector.singularize(self, locale)
  end
end
