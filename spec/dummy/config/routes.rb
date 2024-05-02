# frozen_string_literal: true

Rails.application.routes.draw do
  resources :faqs, only: %i[index] do
    patch :order, on: :collection
  end
  resources :people, only: %i[index]
  resources :resources, only: %i[index show]
  put "resources/active", to: "resources#activate"

  namespace :admin do
    resources :resources, only: %i[index]
  end

  resources :parent, only: [] do
    scope module: :nested do
      resources :children, only: %i[index]
    end
  end

  root to: "application#show"
end
