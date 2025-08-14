# Redis session store configuration
Rails.application.config.session_store :redis_session_store,
  key: '_cargo_link_session',
  redis: {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/2')
  },
  expire_after: 2.weeks,
  secure: ENV.fetch('SESSION_SECURE', 'false') == 'true',  # Use env variable
  httponly: true,
  same_site: :lax