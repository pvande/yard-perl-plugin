module YARD
  module Serializers
    class PODSerializer < FileSystemSerializer
      # Creates a new PODSerializer with options
      #
      # @option opts [String] :basepath ('.') the base path to write data to
      # @option opts [String] :extension ('pod') the extension of the serialized
      #   path filename. If this is set to the empty string, no extension is used.
      def initialize(opts = {})
        super
        @basepath = (options[:basepath] || '.').to_s
        @extension = (options.has_key?(:extension) ? options[:extension] : 'pod').to_s
      end

      # Serializes object with data to its serialized path (prefixed by the {#basepath}).
      #
      # @return [String] the written data (for chaining)
      def serialize(object, data)
        path = File.join(basepath, *serialized_path(object))
        log.debug "Serializing to #{path}"
        File.open!(path, "wb") {|f| f.write data }
      end

      # Implements the serialized path of a code object.
      #
      # @param [CodeObjects::Base, String] object the object to get a path for.
      #   The path of a string is the string itself.
      # @return [String] if object is a String, returns
      #   object, otherwise the path on disk (without the basepath).
      def serialized_path(object)
        return object if object.is_a?(String)
        file = object.files.first[0]
        return file.sub(/#{File.extname(file)}$/, ".#{@extension}")
      end
    end
  end
end
