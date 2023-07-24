# frozen_string_literal: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true

pin_all_from Katalyst::Tables::Engine.root.join("app/assets/javascripts"),
             # preload in tests so that we don't start clicking before controllers load
             preload: Rails.env.test?
