max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 15 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { 5 }
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

workers ENV.fetch("WEB_CONCURRENCY") { 3 }

preload_app!

plugin :tmp_restart
