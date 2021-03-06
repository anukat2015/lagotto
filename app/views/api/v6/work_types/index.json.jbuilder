json.meta do
  json.status "ok"
  json.set! :"message-type", "work_type-list"
  json.set! :"message-version", "6.0.0"
  json.total @work_types.size
end

json.work_types @work_types do |work_type|
  json.cache! ['v6', work_type], skip_digest: true do
    json.(work_type, :id, :title, :container, :timestamp)
  end
end
