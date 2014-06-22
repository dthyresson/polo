Rails.application.routes.draw do

  root to: 'home#show'

  get '/:short_url', to: 'votes#show', as: "vote_short_url", constraints: { short_url: /[a-zA-Z0-9]{6}/ }

  resources :votes, only: [:show, :update]

  scope module: :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :polls, only: [:index, :show, :create] do
        put 'close', on: :member
      end

      resources :votes, only: [:show, :update]
    end
  end
end
