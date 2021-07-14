class BlogComponent < Prawn::Component::Base
  renders_many :articles, ArticleComponent

  def call
    pdf.push '<blog>'

    articles.each(&:draw)

    pdf.push '</blog>'
  end
end
