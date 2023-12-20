# frozen_string_literal: true

Rails.application.routes.draw do
  resources :resources, only: %i[index]

  namespace :admin do
    resources :resources, only: %i[index]
  end

  resources :parent, only: [] do
    scope module: :nested do
      resources :children, only: %i[index]
    end
  end
end
