ReviewSite::Application.routes.draw do

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  resources :reviewing_groups, except: [:show]

  resources :associate_consultants, only: [:index]

  match "/reviews/:review_id/feedbacks/new_additional",
        to: "feedbacks#new_additional",
        as: "additional_review_feedback",
        via: [:get]

  match "/reviews/:review_id/feedbacks/:id/edit_additional",
        to: "feedbacks#edit_additional",
        as: "edit_additional_review_feedback",
        via: [:get]

  resources :reviews do
    member do
      get :summary
      get :send_email
      post :send_reminder_to_all
    end

    collection do
      get :coachees
    end

    resources :feedbacks, except: [:index] do
      member do
        put :submit
        put :unsubmit
        post :send_reminder
        get :preview
      end
    end

    resources :self_assessments, except: [:index, :show]

    resources :invitations, only: [:new, :create, :destroy] do
      member do
        post :send_reminder
      end
    end
  end


  root to: "welcome#index"

  match "/auth/:provider/callback" => "sessions#callback",
       as: "sessions_callback"

  resources :welcome, only: [:index] do
    collection do
      get "help"
      get "contributors"
    end
  end

  resources :users do
    get :get_users, on: :collection
    get :feedbacks, on: :member
    get :completed_feedback, on: :member
  end

  devise_for :additional_emails

  get "users/:id/add_email", to: "users#add_email"
  get "users/:id/remove_email", to: "users#remove_email"

  if ENV["OKTA-TEST-MODE"]
    post "/set_temp_okta", to: "sessions#set_temp_okta"
  end

end
