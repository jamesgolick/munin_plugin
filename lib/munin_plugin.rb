class MuninPlugin
  class Attribute
    undef_method :load if method_defined? :load
    undef_method :type if method_defined? :type

    attr_reader :name, :args

    def initialize(*args)
      if args.first.is_a?(Attribute)
        @name = [args.shift.name, args.shift].join(".")
      else
        @name = args.first
      end

      @args = args
    end

    def method_missing(method, *args, &block)
      @name = [name, method].join(".")
      @args = args
      self
    end

    def to_s
      [name, *args].uniq.join(' ')
    end
  end

  class Collector
    undef_method :load if method_defined? :load
    undef_method :type if method_defined? :type

    def initialize(&block)
      instance_eval(&block)
    end

    def proxy_attributes
      @proxy_attributes ||= []
    end

    def method_missing(method, *args, &block)
      item = Attribute.new(method, *args, &block)
      proxy_attributes << item
      item
    end

    def collect(&block)
      if block_given?
        @collect = block
      end
      @collect
    end

    def to_s
      proxy_attributes.map { |c| c.to_s }.join("\n") + "\n"
    end
  end

  attr_reader :config

  def initialize(&block)
    @config = Collector.new(&block)
  end

  def display_config
    print config
  end

  def display_value
    print Collector.new(&config.collect)
  end

  def run
    ARGV.first == "config" ? display_config : display_value
  end
end

# yeah, yeah :-)
def munin_plugin(&block)
  MuninPlugin.new(&block).run
end
