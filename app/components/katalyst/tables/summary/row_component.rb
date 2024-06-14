# frozen_string_literal: true

module Katalyst
  module Tables
    module Summary
      class RowComponent < ViewComponent::Base
        renders_one :header, Summary::HeaderComponent
        renders_one :body, Summary::BodyComponent
      end
    end
  end
end
