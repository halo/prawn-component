class ButtonComponent < Prawn::Component::Base
  renders_one :title

  def call
    pdf.push '<<'

    title&.draw

    pdf.push '>>'
  end
end
