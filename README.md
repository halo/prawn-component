[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://github.com/halo/prawn-component/blob/master/LICENSE.md)

## TL;DR

This is an implementation of the popular [view_component](https://viewcomponent.org) gem for Prawn.

## Usage

Define a component. You might want to call it something else than "component", because it's likely that you're using the `view_component` gem, too.

```ruby
# app/widgets/box_widget.rb
class BoxWidget < Prawn::Component::Base
  renders_one :title
  renders_one :description
  renders_many :comments, CommentComponent

  option :color, default: { 'ff0000' }

  def call
    pdf.text 'I am a box', color: color
    title&.draw

    pdf.font_size 12
    description&.draw

    comments.each(&:draw)
  end
end

# app/widgets/comment_widget.rb
class CommentComponent < Prawn::Component::Base
  option :record
  renders_one :share

  def call
    pdf.text "Comment (#{record.date})"
    pdf.text record.details

    share&.draw
  end
end
```

And when generating the PDF, you can use the component:

```ruby
BoxWidget.new(color: '00ff00').render_in(pdf) do |box|
  box.title do
    pdf.text 'I am the title'
  end

  box.description do
    pdf.svg 'unicorns.svg'
  end

  @comments.each do |comment|
    box.comment(record: comment) do |comment|
      comment.share do
        pdf.text "Share this with #{@likes[comment.id]} others."
      end
    end
  end
end
```

## Caveats

Rendering a Rails view is pretty simple compared to a PDF.
Because you simply pre-generate an HTML String that you can wrap or concatenate.

In Prawn, the "view" is a living PDF document and you cannot pre-generate any content. In fact, it is not even clear what is meant by content, would it be a `pdf.text` statement, or a `pdf.formatted_text` statement?

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
