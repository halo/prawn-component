[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://github.com/halo/prawn-component/blob/master/LICENSE.md)

## TL;DR

This is an implementation of the popular [view_component](https://viewcomponent.org) gem for Prawn.

## Usage

You define a component just like you would using the `view_component` gem. The only difference, of course, is that you
don't have templates. We're in all-ruby land and the implementation resides in the `#call` method.

```ruby
# app/components/hello_world_component.rb
class HelloWorldComponent < Prawn::Component
  def call
    pdf.text 'Hello World!'
  end
end
```

To render a component into an existing PDF, use the `#render_in` method:

```ruby
# app/models/generate_some_pdf.rb
pdf = Prawn::Document.new

HelloWorldComponent.new.render_in(pdf)
```

You can use `renders_one` and `renders_many` to use subcomponents.
In fact, when using your component with a block, you must at least use `renders_one` to pass in your content.

```ruby
# app/components/box_component.rb
class BoxComponent < Prawn::Component
  renders_one :title, TitleComponent
  renders_one :description
  renders_many :comments

  def call
    pdf.text 'This is a box'
    title.draw # In Rails you would simply use `#to_s` but we use `#draw`.
    description.draw
    comments.each(&:draw)
  end
end

# app/components/title_component.rb
class TitleComponent < Prawn::Component
  renders_one :content

  def call
    pdf.font_size 14
    content.draw
  end
end
```

And then render the component:

```ruby
# app/models/generate_some_pdf.rb
pdf = Prawn::Document.new

BoxComponent.new.render_in(pdf) do |box|
  box.title do
    pdf.text 'I am the title'
  end

  box.description do
    pdf.text 'I am the description'
  end

  box.comment do
    pdf.text 'First comment'
  end

  box.comment do
    pdf.text 'Second comment'
  end
end
```

You can define params and options like with the [dry-initializer](https://dry-rb.org/gems/dry-initializer) gem.

```ruby
# app/components/title_component.rb
class SayItComponent < Prawn::Component
  option :message

  def call
    pdf.text message
  end
end
```

And call it like so:

```ruby
# app/models/generate_some_pdf.rb
pdf = Prawn::Document.new

SayItComponent.new(message: 'Hello!').render_in(pdf) do |box|
```

Of course you could render a component inside of another component:

```ruby
# app/components/blog_component.rb
class BlogComponent < Prawn::Component
  renders_many :articles, ArticleComponent

  def call
    pdf.push 'Welcome to my blog'
    articles.each(&:draw)
  end
end

# app/components/article_component.rb
class ArticleComponent < Prawn::Component
  renders_one :title
  renders_one :body

  def call
    TitleComponent.new.render_in(pdf) do |title|
      title.content do
        title.draw
      end
    end

    body.draw
  end
end
```

And render it:

```ruby
# app/models/generate_some_pdf.rb
pdf = Prawn::Document.new
@comments = load_some_comments!

BlogComponent.new.render_in(pdf) do |blog|
  blog.article do |article|
    article.title do
      pdf.text 'Breaking news'
    end

    article.body do
      pdf.text 'The weather is good.'
    end
  end
end
```

## Caveats

Rendering a Rails view is pretty simple compared to a PDF.
Because you simply pre-generate an HTML String that you can wrap or concatenate.

In Prawn, the "view" is a living PDF document and you cannot pre-generate any content.

That means, we cannot use wrappers like this:

```ruby
# Would be nice but does NOT work.
ButtonComponent.new.render_in(pdf) do
  pdf.text 'I am a button'
end
```

Instead we're forced to use this:

```ruby
# Cumbersome, but it has its advantages.
ButtonComponent.new.render_in(pdf) do |button|
  button.title do
    pdf.text 'I am a button'
  end
end
```

The technical reason behind this is this:

```ruby
# This causes a problem for the block/yield mechanism.
BoxComponent.new.render_in(pdf) do |box|
  box.title do
    pdf.text 'I am the title'
  end

  pdf.text 'I am the description'
end
```

In this example, the box title is first properly set-up when the entire block is exectued. But executing that block already modifies the pdf in-place (with the description). Which makes this uninituitive (in Rails you would just capture the output of the description block and keep it for later use, that's not possible in a PDF).

So you have to use either or: blocks never have arguments or always (which we chose here for this gem).

## History

When it comes to "resusable components", it's really hard to find the balance between too much opinion and too much flexibility.

For Prawn it might look like
[this](https://github.com/kaspermeyer/canned_tuna/blob/ea4e05a4ff7b10cd73c3bb3246173a9f0f749b40/example/outlets.rb#L26-L28)
or like
[this](https://github.com/prawnpdf/prawn-component/blob/af0c1e6c9fcac7d036c024a53e18dfe563eb50e3/example/simple.rb#L3)
or
[this](https://github.com/neume/sugpoko/blob/1e81c069f6a6cb58431866b1090667d5b8d783ad/README.md#usage).
For Rails you might come up with something like
[this](https://github.com/github/view_component/blob/0afe05da0c3ea5ce99dc431447bcb61359bc6e09/docs/content_areas.md)
but that's not good enough, so let's use
[this](https://github.com/github/view_component/blob/0afe05da0c3ea5ce99dc431447bcb61359bc6e09/docs/slots_v1.md)
and after years of iterations, we finally landed
[here](https://viewcomponent.org/guide/slots.html).

So, now that that API is somewhat stable, I felt it was time to use it with Prawn.

## Requirements

* Ruby >= 2.3.0 (something like that)

## Copyright

MIT 2021 halo. See [MIT-LICENSE](http://github.com/halo/prawn-component/blob/master/LICENSE.md).
