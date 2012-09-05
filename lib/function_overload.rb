module Overloadable
  class OverloadedMethod
    attr_accessor :arguments, :aliased_name

    def initialize(original_name, arguments)
      @arguments = arguments
      @aliased_name = generate_alias(original_name)
    end

    def respond_tos
      @respond_tos ||= @arguments.map do |a|
        raw_method_name = a.last.to_s.split('_', 2).last # :a_nil_p => :nil_p
        raw_method_name.sub(/_p$/, '?').to_sym           # "nil_p"  => :nil?
      end
    end

    def generate_alias(original_name)
      [original_name, rand(9_000) + 1_000].map(&:to_s).join('_').to_sym
    end

    def supports?(args)
      return false unless args.length == @arguments.length
      respond_tos.zip(args).all? { |x| x.last.respond_to? x.first }
    end
  end

  def method_added(method_name)
    return if @_dont_overload_method
    @_overloaded_methods ||= {}
    @_overloaded_methods[method_name] ||= []
    m = OverloadedMethod.new(method_name, instance_method(method_name).parameters)
    @_overloaded_methods[method_name] << m
    @_dont_overload_method = true
    alias_method m.aliased_name, method_name
    build_dispatcher(method_name)
    @_dont_overload_method = false
  end


  def build_dispatcher(method_name)
    define_method(method_name) do |*args|
      overloaded_methods = self.class.instance_variable_get("@_overloaded_methods")[method_name]
      target = overloaded_methods.detect { |m| m.supports? args }
      if target
        send(target.aliased_name, *args)
      else
        raise ArgumentError.new("No signature found for #{method_name.inspect} on #{self.inspect}.")
      end
    end
  end
end
