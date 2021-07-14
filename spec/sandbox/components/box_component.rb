class BoxComponent < Prawn::Component
  renders_one :title
  renders_one :description

  def call
    pdf.push '<<'

    title&.draw
    description&.draw

    pdf.push '>>'
  end
end
