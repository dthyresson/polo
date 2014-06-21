Rails.application.routes.draw do
  scope module: :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :polls, only: [:index, :show, :create] do
        put 'close', on: :member
      end

      resources :votes, only: [:show, :update]
    end
  end
end
