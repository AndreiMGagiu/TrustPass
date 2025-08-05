Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :purchases, only: [:create] do
        collection do
          post :check, to: 'purchases/checks#create'
        end
      end

      namespace :customer do
        resources :returns, only: [:create]
      end
    end
  end
end
