json.meta do
  json.status "ok"
  json.message_type "publisher"
  json.message_version "6.0.0"
end

json.publisher do
  json.cache! ['v6', @publisher], skip_digest: true do
    json.(@publisher, :id, :title, :other_names, :prefixes, :update_date)
  end
end
