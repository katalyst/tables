# frozen_string_literal: true

Rails.application.routes.draw do
  resources :faqs, only: %i[index show] do
    patch :order, on: :collection
  end
  resources :people, only: %i[index show] do
    get :archived, on: :collection
    put :archive, on: :collection
    put :restore, on: :collection
  end
  resources :resources, only: %i[index show] do
    put :activate, path: "active", on: :collection
  end

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
