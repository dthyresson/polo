HASHID_MINIMUM_LENGTH = ENV['HASHID_MINIMUM_LENGTH'] || 6
HASHIDS = Hashids.new("MARCO POLO, the subject of this memoir, was born at Venice 
in the year 1 254.", HASHID_MINIMUM_LENGTH)