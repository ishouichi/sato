Rails.application.routes.draw do
  devise_for :users

  # 主催者用認証
  devise_for :organizers,
             path: 'organizers',
             controllers: {
               sessions: 'organizers/sessions',
               registrations: 'organizers/registrations',
               passwords: 'organizers/passwords'
             }

  devise_scope :organizer do
    post 'organizers/switch_from_user', to: 'organizers/sessions#switch_from_user', as: :switch_to_organizer_from_user
  end

  # 主催者向け管理画面（認証必須）
  namespace :organizers do
    authenticate :organizer do
      root 'dashboard#index', as: :dashboard
      get 'dashboard', to: 'dashboard#index'

      # 組織設定
      get 'organization/setup', to: 'organizations#setup'
      get 'organization/edit', to: 'organizations#edit'
      patch 'organization', to: 'organizations#update'
      post 'organization', to: 'organizations#create'

      # プロフィール設定
      get 'profile', to: 'profiles#edit'
      patch 'profile', to: 'profiles#update'
      post 'profile/switch_to_user', to: 'profiles#switch_to_user', as: :profile_switch_to_user

      # 祭り管理
      resources :festivals, only: %i[index new create edit update destroy] do
        resources :participants, only: %i[index update]
      end
    end
  end

  get "home/index"

  # 参加者向け祭り・参加申込
  resources :festivals, only: %i[index show] do
    resources :festival_participations, only: %i[new create], path: 'participations' do
      patch :cancel, on: :member
    end
  end
  get 'participations', to: 'festival_participations#index', as: :user_participations
  get 'participations/history', to: 'festival_participations#history', as: :user_past_participations

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
