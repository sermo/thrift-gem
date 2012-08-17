# encoding: ascii-8bit
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

require 'net/http'
require 'net/https'
require 'uri'
require 'stringio'

module Thrift
  class HTTPClientTransport < BaseTransport
    def initialize(url, additional_headers = {})
      @url = URI url
      @outbuf = ""
      @additional_headers = additional_headers || {}
    end

    def open?; true end
    def read(sz); @inbuf.read sz end
    def write(buf); @outbuf << buf end
    def flush
      http = Net::HTTP.new @url.host, @url.port
      http.use_ssl = @url.scheme == "https"
      headers = { 'Content-Type' => 'application/x-thrift' }.merge(@additional_headers)
      begin
         resp, data = http.post(@url.path, @outbuf, headers)
         unless resp.code == "200"
            Rails.logger.error "Failed Thrift call to #{@url} with http status: #{resp.code} and data >>>> \n #{data} \n <<<< data"
            raise "Request to service failed w/ http status: #{resp.code}"
         end
      ensure
         @inbuf = StringIO.new( data || '' )
      @outbuf = ""
    end
  end
  end
end
