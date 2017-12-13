module ReactiveRuby
  class ComponentLoader
    attr_reader :v8_context
    private :v8_context

    def initialize(v8_context)
      unless v8_context
        raise ArgumentError.new('Could not obtain ExecJS runtime context')
      end
      @v8_context = v8_context
    end

    def load(file = components)
      return true if loaded?
      !!v8_context.eval(opal(file))
    end

    def load!(file = components)
      return true if loaded?
      load(file)
    ensure
      raise "No react.rb components found in #{components}.rb" unless loaded?
    end

    def loaded?
      !!v8_context.eval('Opal.React !== undefined')
    rescue ::ExecJS::Error
      false
    end

    private

    def components
      opts = ::Rails.configuration.react.server_renderer_options
      return opts[:files].first.gsub(/.js$/, '') if opts && opts[:files]
      'components'
    end

    def opal(file)
      if Opal::Processor.respond_to?(:load_asset_code)
        Opal::Processor.load_asset_code(assets, file)
      else
        Opal::Sprockets.load_asset(file, assets)
      end
    rescue # What exception is being caught here?
    end

    def assets
      ::Rails.application.assets
    end
  end
end
