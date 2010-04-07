include Helpers::ModuleHelper

def init
  options[:objects] = objects = run_verifier(options[:objects]).reject { |e| e.type == :root }
  options[:files] = ([options[:readme]] + options[:files]).compact.map {|t| t.to_s }
  options[:readme] = options[:files].first
  options[:format] = :text  # Tell ERB to supress newlines

  options[:serializer] = YARD::Serializers::PODSerializer.new(options[:serializer].options)

  objects.each do |object|
    begin
      serialize(object)
    rescue => e
      path = options[:serializer].serialized_path(object)
      log.error "Exception occurred while generating '#{path}'"
      log.backtrace(e)
    end
  end
end

def serialize(object)
  Templates::Engine.with_serializer(object, options[:serializer]) do
    summary = object.docstring.summary

    @title = object.path + ' -- ' + summary
    @docstring = object.docstring.sub(/#{summary}\n*/, '')
    @object = object
    @methods = prune_method_listing(object.meths, false)
    @see_also = [object.superclass, object.docstring.tags(:see) ].flatten.reject { |e| e.name == :Object }

    erb(:package)
  end
end