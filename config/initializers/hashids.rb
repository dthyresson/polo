HASHID_MINIMUM_LENGTH = ENV['HASHID_MINIMUM_LENGTH'] || 6
HASHID_SALT = ENV['HASHID_SALT'] || "MARCO POLO, the subject of this memoir, was born at Venice in the year 1 254."

HASHIDS = Hashids.new(HASHID_SALT, HASHID_MINIMUM_LENGTH)
