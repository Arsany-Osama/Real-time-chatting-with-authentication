Rails.application.routes.draw do
     devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
     #sigin for user model by devise and callback by controller omniauth_callbacks
     root 'home#index' #root go to index action in home controller
     resources :chats, only: [:index, :show, :create, :edit, :update, :destroy]
     # CRUD operation by RESTFul routes for chats controller
=begin
chats#index - GET /chats - list all chats
chats#show - GET /chats/:id - show a specific chat
chats#create - POST /chats - create a new chat
chats#edit - GET /chats/:id/edit - edit a specific chat
chats#update - PATCH/PUT /chats/:id - update a specific chat
chats#destroy - DELETE /chats/:id - delete a specific chat
=end
   end
