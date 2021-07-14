class ArticleComponent < Prawn::Component::Base
  renders_one :title, -> {}
  renders_one :body, -> {}

  option :featured, default: -> { false }

  def call
    pdf.push "<article#{' featured' if featured}>"

    pdf.push '<title>'
    title&.draw
    pdf.push '</title>'

    pdf.push '<body>'
    body&.draw
    pdf.push '</body>'

    pdf.push '</article>'
  end
end
