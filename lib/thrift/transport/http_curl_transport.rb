# Added by Sermo

require 'uri'
require 'stringio'

module Thrift
   class HTTPCurlTransport < BaseTransport
      attr_reader :headers
      attr_accessor :additional_headers

      def initialize(url, extra_headers = {})
         @url = URI url
         @outbuf = ''
         @headers = {
            'Content-Type' => 'application/x-thrift',
            'User-Agent' => 'ThriftMonkey::ThriftClient'
         }.freeze
         @additional_headers = extra_headers
      end

      def patron_session
         sess = ::Patron::Session.new
         sess.base_url = "#{@url.scheme}://#{@url.host}:#{@url.port}"
         # these timeouts are probably way too high
         sess.connect_timeout = 60
         sess.timeout = 120
         sess.insecure = true
         sess
      end

      def open?; true end
      def read(sz); @inbuf.read sz end
      def write(buf); @outbuf << buf end

      def flush
         data = ''
         begin
            resp = patron_session.post(@url.path, @outbuf, headers.merge(@additional_headers))
            data << resp.body
            unless resp.status == 200
               Rails.logger.error "Failed Thrift call to #{@url} with http status: #{resp.status} and data >>>> \n #{data} \n <<<< data"
               raise "Request to service failed w/ http status: #{resp.status}"
            end
         ensure
            @inbuf = StringIO.new( data )
            @outbuf = ''
         end
      end

   end
end
