# frozen_string_literal: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin_all_from "app/javascript/controllers", under: "controllers"

pin "application"
