class HelloWorldComponent < Prawn::Component::Base
  def call
    pdf.push 'Hello World!'
  end
end
