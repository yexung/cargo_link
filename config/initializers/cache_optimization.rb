# Fragment caching optimization
Rails.application.configure do
  # Enable fragment caching in development for testing
  config.action_controller.perform_caching = true
  
  # Enable view caching
  config.action_view.cache_template_loading = true
  
  # Optimize Active Record
  config.active_record.cache_versioning = true
  
  # Enable query log tags for debugging
  config.active_record.query_log_tags_enabled = true
end

# Preload commonly used data to Redis
Rails.application.config.after_initialize do
  # Cache popular vehicle brands
  Rails.cache.fetch("popular_brands", expires_in: 1.hour) do
    %w[현대 기아 BMW 벤츠 아우디 폭스바겐 토요타 혼다 닛산 렉서스]
  end
  
  # Cache fuel types
  Rails.cache.fetch("fuel_types", expires_in: 1.hour) do
    %w[가솔린 디젤 LPG 하이브리드 전기 수소 CNG 기타]
  end
end