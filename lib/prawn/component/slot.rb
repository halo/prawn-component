module Prawn
  module Component
    # Adaptation of https://github.com/github/view_component/blob/a4e7296a6158a8656a0cd7bc868e1533cd4ee7d8/lib/view_component/slot_v2.rb
    # But without string capturing.
    #
    # Copyright (c) 2019 GitHub
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    #
    class Slot
      attr_writer :_component_instance, :_content_block

      def initialize(parent)
        @parent = parent
      end

      # This is what `to_s` is in the view_component gem.
      # It renders the content into the view context (that is, the PDF)
      def draw
        pdf = @parent.send(:pdf)

        if defined?(@_component_instance)
          @_component_instance.render_in(pdf, &@_content_block)

        elsif defined?(@_content_block)
          @_content_block.call
        end
      end

      # Give a component access to its slot instances through this wrapper.
      def method_missing(symbol, *args, &block)
        @_component_instance.public_send(symbol, *args, &block)
      end

      def respond_to_missing?(symbol, include_all = false)
        defined?(@_component_instance) && @_component_instance.respond_to?(symbol, include_all)
      end
    end
  end
end
