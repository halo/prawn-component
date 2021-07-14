module Prawn
  module Component
    # This is a copy-paste of the `method_object` gem with two modifications:
    #
    # A) At the time of writing this commit has not been released to rubygems.org yet:
    #    https://github.com/bukowskis/method_object/commit/d6ef55bc9ab3f5d52399a4209c97c80aee2441cd
    #
    # B) We are not making `.new` a private class method. We want it public.
    #
    # Copyright 2018 Bukowskis
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
    module MethodObject
      def self.included(base)
        base.extend Dry::Initializer
        base.extend ClassMethods
      end

      module ClassMethods
        def call(*args, **kwargs, &block)
          __check_for_unknown_options(*args, **kwargs)

          if kwargs.empty?
            # Preventing `Passing the keyword argument as the last hash parameter is deprecated`
            new(*args).call(&block)
          else
            new(*args, **kwargs).call(&block)
          end
        end

        # Overriding the implementation of `#param` in the `dry-initializer` gem.
        # Because of the positioning of multiple params, params can never be omitted in a method object.
        def param(name, type = nil, **opts, &block)
          raise ArgumentError, "Default value for param not allowed - #{name}" if opts.key? :default
          raise ArgumentError, "Optional params not supported - #{name}" if opts.fetch(:optional, false)

          super
        end

        def __check_for_unknown_options(*args, **kwargs)
          return if __defined_options.empty?

          # Checking params
          opts = args.drop(__defined_params.length).first || kwargs
          raise ArgumentError, "Unexpected argument #{opts}" unless opts.is_a? Hash

          # Checking options
          unknown_options = opts.keys - __defined_options
          message = "Key(s) #{unknown_options} not found in #{__defined_options}"
          raise KeyError, message if unknown_options.any?
        end

        def __defined_options
          dry_initializer.options.map(&:source)
        end

        def __defined_params
          dry_initializer.params.map(&:source)
        end
      end
    end
  end
end
