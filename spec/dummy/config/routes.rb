# frozen_string_literal: true

Rails.application.routes.draw do
  get :resource, to: "application#show"
end
