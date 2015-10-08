require 'pg'
require 'uri'

module Redshift
  module Client
    module ConnectionHandling
      def establish_connection(config = {})
        disconnect
        initialize_thread!
        configure!(config)
      end

      def disconnect
        connection.finish if connected?
        cleanup_thread!
      end

      def connected?
        !!(thread && thread[:connection])
      end

      def established?
        !!(thread && thread[:configurations])
      end

      def connection
        raise ConnectionNotEstablished.new unless established?

        if connected?
          thread[:connection]
        else
          connect!
        end
      end

      private
      def initialize_thread!
        Thread.current[:redshift] = {}
      end

      def cleanup_thread!
        Thread.current[:redshift] = nil
      end

      def thread
        Thread.current[:redshift]
      end

      def connect!
        thread[:connection] = PG.connect(thread[:configurations].to_hash)
      end

      def configure!(config)
        thread[:configurations] = Configuration.parse(config)
      end
    end
  end
end