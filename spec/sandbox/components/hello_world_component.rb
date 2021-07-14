class HelloWorldComponent < Prawn::Component
  def call
    pdf.push 'Hello World!'
  end
end
