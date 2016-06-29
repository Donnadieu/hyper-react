module React
  module Component

    def deprecated_params_method(name, *args, &block)
      React::Component.deprecation_warning"Direct access to param `#{name}`.  Use `params.#{name}` instead."
      params.send(name, *args, &block)
    end

    class PropsWrapper
      attr_reader :props

      def self.define_param(name, param_type, owner)
        owner.define_method("#{name}") do |*args, &block|
          deprecated_params_method("#{name}", *args, &block)
        end
        if param_type == Observable
          owner.define_method("#{name}!") do |*args|
            deprecated_params_method("#{name}!", *args)
          end
          define_method("#{name}") do
            value_for(name)
          end
          define_method("#{name}!") do |*args|
            current_value = value_for(name)
            if args.count > 0
              props[name].call args[0]
              current_value
            else
              # rescue in case we in middle of render... What happens during a
              # render that causes exception?
              # Where does `dont_update_state` come from?
              props[name].call current_value unless @dont_update_state rescue nil
              props[name]
            end
          end
        elsif param_type == Proc
          define_method("#{name}") do |*args, &block|
            props[name].call(*args, &block) if props[name]
          end
        else
          define_method("#{name}") do
            if @processed_params.has_key? name
              @processed_params[name]
            else
              @processed_params[name] = if param_type.respond_to? :_react_param_conversion
                param_type._react_param_conversion props[name]
              elsif param_type.is_a?(Array) &&
                param_type[0].respond_to?(:_react_param_conversion)
                props[name].collect do |param|
                  param_type[0]._react_param_conversion param
                end
              else
                props[name]
              end
            end
          end
        end
      end

      def unchanged_processed_params(new_props)
        Hash[
          *@processed_params.collect do |key, value|
            [key, value] if @props[key].equal? new_props[key] # `#{@props[key]} == #{new_props[key]}`
          end.compact.flatten(1)
        ]
      end

      def initialize(props, current_props_wrapper=nil)
        @props = props || {}
        @processed_params = if current_props_wrapper
          current_props_wrapper.unchanged_processed_params(props)
        else
          {}
        end
      end

      def [](prop)
        props[prop]
      end

      private

      def value_for(name)
        self[name].instance_variable_get("@value") if self[name]
      end
    end
  end
end
