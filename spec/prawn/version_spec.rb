require 'spec_helper'

RSpec.describe Prawn::Components::VERSION do
  context '.STRING' do
    it 'is the version as String' do
      version = described_class::STRING

      expect(version).to eq '1.0.0'
    end
  end
end
