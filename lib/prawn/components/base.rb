module Prawn
  module Components
    # Adaptation of to https://github.com/github/view_component/blob/a4e7296a6158a8656a0cd7bc868e1533cd4ee7d8/lib/view_component/base.rb
    # But without action view and caching.
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
    class Base
      include ::Prawn::Components::MethodObject

      class_attribute :registered_slots
      self.registered_slots = {}

      def self.renders_one(slot_name, callable = nil)
        define_method slot_name do |*args, **kwargs, &block|
          if args.empty? && kwargs.empty? && block.nil?
            get_slot(slot_name)
          else
            set_slot(slot_name, *args, **kwargs, &block)
          end
        end

        register_slot(slot_name, collection: false, callable: callable)
      end

      def self.renders_many(slot_name, callable = nil)
        singular_name = ActiveSupport::Inflector.singularize(slot_name)

        # Define setter for singular names
        # e.g. `renders_many :items` allows fetching all tabs with
        # `component.tabs` and setting a tab with `component.tab`
        define_method singular_name do |*args, **kwargs, &block|
          set_slot(slot_name, *args, **kwargs, &block)
        end

        # Instantiates and and adds multiple slots forwarding the first
        # argument to each slot constructor
        define_method slot_name do |collection_args = nil, &block|
          if collection_args.nil? && block.nil?
            get_slot(slot_name)
          else
            collection_args.each do |args|
              set_slot(slot_name, **args, &block)
            end
          end
        end

        register_slot(slot_name, collection: true, callable: callable)
      end

      # Clone slot configuration into child class
      # see #test_slots_pollution
      def self.inherited(child)
        child.registered_slots = self.registered_slots.clone
        super
      end

      # PRIVATE

      def self.register_slot(slot_name, collection:, callable:)
        # Setup basic slot data
        slot = {
          collection: collection,
        }
        # If callable responds to `render_in`, we set it on the slot as a renderable
        if callable && callable.respond_to?(:method_defined?) && callable.method_defined?(:render_in)
          slot[:renderable] = callable

        elsif callable.is_a?(String)
          # If callable is a string, we assume it's referencing an internal class
          slot[:renderable_class_name] = callable

        elsif callable
          # If slot does not respond to `render_in`, we assume it's a proc,
          # define a method, and save a reference to it to call when setting
          method_name = :"_call_#{slot_name}"
          define_method method_name, &callable
          slot[:renderable_function] = instance_method(method_name)
        end

        # Register the slot on the component
        self.registered_slots[slot_name] = slot
      end
      private_class_method :register_slot

      def set_slot(slot_name, *args, **kwargs, &block)
        slot_definition = self.class.registered_slots[slot_name]

        slot = Slot.new(self)

        # Passing the block to the sub-component wrapper like this has two
        # benefits:
        #
        # 1. If this is a `content_area` style sub-component, we will render the
        # block via the `slot`
        #
        # 2. Since we have to pass block content to components when calling
        # `render`, evaluating the block here would require us to call
        # `view_context.capture` twice, which is slower
        slot._content_block = block if block_given?

        if slot_definition[:renderable]
          # If class
          slot._component_instance = slot_definition[:renderable].new(*args, **kwargs)

        elsif slot_definition[:renderable_class_name]
          # If class name as a string
          slot._component_instance = self.class.const_get(slot_definition[:renderable_class_name]).new(*args, **kwargs)

        elsif slot_definition[:renderable_function]
          # If passed a lambda
          # Use `bind(self)` to ensure lambda is executed in the context of the
          # current component. This is necessary to allow the lambda to access helper
          # methods like `content_tag` as well as parent component state.
          renderable_value = slot_definition[:renderable_function].bind(self).call(*args, **kwargs, &block)

          # Function calls can return components, so if it's a component handle it specially
          if renderable_value.respond_to?(:render_in)
            slot._component_instance = renderable_value
          end
        end

        @_set_slots ||= {}

        if slot_definition[:collection]
          @_set_slots[slot_name] ||= []
          @_set_slots[slot_name].push(slot)
        else
          @_set_slots[slot_name] = slot
        end

        nil
      end


      def get_slot(slot_name)
        slot = self.class.registered_slots[slot_name]
        @_set_slots ||= {}

        if @_set_slots[slot_name]
          return @_set_slots[slot_name]
        end

        if slot[:collection]
          []
        else
          nil
        end
      end

      def render_in(pdf, &block)
        @pdf = pdf

        # We have to yield eventually, because otherwise the components block would not be executed.
        # Also, we have to yield before trying to draw subcomponents (because they are set up by executing the block).
        # It's unintuitive to leave that up to the developer to figure out in all their components.
        # So, we keep things simple and always yield right away, so everything is set up properly.
        # The downside is that this forces `renders_one` subcomponents instead of simply `yield` to render the block.
        yield self if block_given?

        call if render?
      end

      private

      attr_reader :pdf

      # Override this with logic in your component.
      def render?
        true
      end
    end
  end
end
