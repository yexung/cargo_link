# Performance optimizations
Rails.application.configure do
  # Enable query caching
  config.active_record.cache_versioning = true
  
  # Optimize autoloading
  config.enable_reloading = false if Rails.env.production?
end

# Background job optimizations
ActiveJob::Base.queue_adapter = :inline  # For development, use inline processing