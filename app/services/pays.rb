# frozen_string_literal: true

class Pays

  def initialize
    @mapping = YAML.safe_load(File.read(File.join(Rails.root, "/app/jobs/code_pays.yml")))
  end

  def a_partir_du_code(code)
    return "SANS PAYS" if code.blank?

    @mapping[code.to_i]
  end

end
