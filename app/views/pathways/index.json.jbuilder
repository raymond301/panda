json.array!(@pathways) do |pathway|
  json.extract! pathway, :id
  json.url pathway_url(pathway, format: :json)
end
