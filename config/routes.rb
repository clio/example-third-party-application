Rails.application.routes.draw do
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
