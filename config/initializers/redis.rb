# Redis configuration
$redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))

# Set up Redis for cache store
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
    namespace: 'cargo_link_cache'
  }
end