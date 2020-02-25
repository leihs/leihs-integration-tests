class Field < Sequel::Model(:fields)
end
Field.unrestrict_primary_key
