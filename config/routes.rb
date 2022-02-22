Rails.application.routes.draw do
  root "welcome#index"

  resource controller: "application", only: [] do
    get "authenticate_with_identity"
    get "identity_callback"
    get "manage_callback"
    get "signout"
  end

  get "welcome/index"
  get "profile/index"
  get "matter/index"
  get "matter/paginate"
end
