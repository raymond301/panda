json.array!(@annotation_collections) do |annotation_collection|
  json.extract! annotation_collection, :id
  json.url annotation_collection_url(annotation_collection, format: :json)
end
