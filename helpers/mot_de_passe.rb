helpers do
	def normalise date
    return date if date =~ /\d{4}-\d\d-\d\d/
    if date =~ /^(\d\d)\/(\d\d)\/(\d{4})/ or date =~ /^(\d\d)\s(\d\d)\s(\d{4})/
      return "#{$3}-#{$2}-#{$1}"
    end
  end
end