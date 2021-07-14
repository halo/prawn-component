class StreetComponent < Prawn::Component
  renders_many :cars

  def call
    cars.each do |car|
      pdf.push 'Car:'
      car.draw
    end
  end
end
