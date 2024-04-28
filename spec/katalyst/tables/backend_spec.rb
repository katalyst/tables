# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Backend do
  include described_class

  describe ".default_table_component" do
    it "changes the default table component" do
      expect { self.class.default_table_component CustomTableComponent }
        .to change(self, :default_table_component).from(nil).to(CustomTableComponent)
    end
  end
end
