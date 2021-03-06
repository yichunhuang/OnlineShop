Rails.application.routes.draw do
  devise_for :users, controllers: { # 如果沒有指定controller就會連到預設devise的controller
        registrations: 'users/registrations',
        sessions: 'users/sessions',
        confirmations: 'users/confirmations',
        passwords: 'users/passwords',
        # omniauth_callbacks: 'users/omniauth_callbacks',
        unlocks: 'users/unlocks'
  }

  mount RailsAdmin::Engine => '/pbadmin', as: 'rails_admin'
  root "products#index"

  resources :products

  resources :cart_items

  resources :orders do
    collection do
      get :admin
    end
  end

  resources :payments

  resources :categories, param: :category_id, except: [:index] do #except, only可以關掉預設但不需要用到的url
  	collection do
  	end

  	member do 
  		get :products

  		resources :subcategories, param: :subcategory_id, only: [] do
  			member do
  				get :products
  			end
  		end
  	end
  	# collection do
    # 	get :products 做出來會是 categories/products，index+url的概念
    # end

    # member do
    # 	get :products 做出來會是 categories/:id/products，show+url的概念
    # end
  end

  # get "admin/log_in", to: "admin#log_in"
  # post "admin/create_session", to: "admin#create_session"
  # get "admin/log_out", to: "admin#log_out"
end