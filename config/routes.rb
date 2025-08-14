Rails.application.routes.draw do
  # 판매자 환전 신청 라우트
  resources :withdrawal_requests, only: [:index, :new, :create, :show]
  namespace :buyers do
    get "dashboard/index"
  end
  namespace :sellers do
    get "dashboard/index"
  end
  devise_for :admin_users
  devise_for :buyers, controllers: { registrations: 'buyers/registrations' }
  devise_for :sellers, controllers: { registrations: 'sellers/registrations' }
  devise_for :users
  root "home#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Main application routes
  resources :vehicles do
    member do
      patch :approve
      patch :reject
    end
  end
  
  resources :auctions do
    member do
      post :place_bid
      patch :end_auction
    end
    resources :bids, only: [:create, :index]
  end

  resources :trades do
    resources :messages, only: [:create, :index]
  end

  resources :payments, only: [:show, :create, :update] do
    member do
      patch :confirm_deposit
    end
  end

  # Admin routes
  namespace :admin do
    get "withdrawal_requests/index"
    get "withdrawal_requests/show"
    root 'dashboard#index'
    resources :dashboard, only: [:index]
    resources :payments, only: [:index, :show] do
      member do
        patch :confirm
        patch :reject
      end
    end
    resources :settings, only: [:index, :update]
    resources :vehicles, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :auctions, only: [:index, :show]
    resources :users, only: [:index, :show, :edit, :update]
    resources :withdrawal_requests, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  # API routes for AJAX
  namespace :api do
    namespace :v1 do
      resources :auctions, only: [:show] do
        resources :bids, only: [:create]
      end
      resources :messages, only: [:create, :index]
    end
  end

  # Sellers namespace routes
  namespace :sellers do
    root 'dashboard#index'
    get :dashboard, to: 'dashboard#index'
    resources :vehicles, except: [:index]
    resources :auctions, except: [:index] do
      member do
        patch :end_auction
      end
    end
    resources :trades, except: [:index] do
      member do
        get :complete_trade
        patch :complete_trade
      end
    end
  end

  # Buyers namespace routes  
  namespace :buyers do
    root 'dashboard#index'
    get :dashboard, to: 'dashboard#index'
    resources :bids, only: [:index, :show]
    resources :payments, only: [:index, :show, :create]
    resources :trades, except: [:new, :create, :edit, :update, :destroy]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
