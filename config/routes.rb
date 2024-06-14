Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "welcome#index"

  resource controller: "application", only: [] do
    get "authenticate_with_identity"
    get "identity_callback"
    get "manage_callback"
    get "auth_popup_callback"
    get "signout"
  end

  resources :welcome, only: [:index]
  resources :profile, only: [:index]
  get "/matter/paginate", to: "matter#paginate"
  resources :matter, only: [:index, :show]
end
