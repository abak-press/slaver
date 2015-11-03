module Slavable
  def switch(*method_names)
    options = method_names.pop

    unless options.is_a?(Hash)
      raise ArgumentError, 'Unable to detect "to" option, usage: "switch :method, :other, ..., to: :connection_name"'
    end

    method_names.each do |method|
      aliased_method, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
      with_name = "#{aliased_method}_with_connection#{punctuation}"
      without_name = "#{aliased_method}_without_connection#{punctuation}"
      connection = options.with_indifferent_access.fetch(:to)

      class_eval <<-eoruby, __FILE__, __LINE__ + 1

        def #{with_name}(*args, &block)
          ::ActiveRecord::Base.within(:#{connection}) { #{without_name}(*args, &block) }
        end
      eoruby

      alias_method without_name, method
      alias_method method, with_name
    end
  end
end
