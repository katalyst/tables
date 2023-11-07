# frozen_string_literal: true

pin_all_from Katalyst::Tables::Engine.root.join("app/assets/javascripts"),
             # preload in tests so that we don't start clicking before controllers load
             preload: Rails.env.test?
