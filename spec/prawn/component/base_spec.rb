require 'spec_helper'

RSpec.describe Prawn::Component::Base do
  describe '#render_in' do
    context 'with a simple call statement' do
      it 'renders the content' do
        pdf = []

        HelloWorldComponent.new.render_in(pdf)

        expect(pdf).to eq ['Hello World!']
      end
    end

    context 'with an explicit block' do
      it 'wraps the block' do
        pdf = []

        BoxComponent.new.render_in(pdf) do |box|
          box.title do
            pdf.push 'TITLE'
          end

          box.description do
            pdf.push 'DESCRIPTION'
          end
        end

        expect(pdf).to eq ['<<', 'TITLE', 'DESCRIPTION', '>>']
      end
    end

    context 'with subcomponents' do
      it 'nests subcomponents' do
        pdf = []

        BlogComponent.new.render_in(pdf) do |blog|
          pdf.push 'Welcome to my Blog'

          blog.article do |article|
            article.title do
              pdf.push 'First Title'
            end

            article.body do
              pdf.push 'First Body'
            end
          end

          blog.article(featured: true) do |article|
            article.title do
              pdf.push 'Second Title'
            end

            article.body do
              pdf.push 'Second Body'
            end
          end
        end

        expect(pdf.join).to eq 'Welcome to my Blog<blog><article><title>First Title</title><body>First Body</body></article><article featured><title>Second Title</title><body>Second Body</body></article></blog>'
      end
    end
  end
end
