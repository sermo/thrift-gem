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

module Thrift
  module Processor
    def initialize(handler)
      @handler = handler
    end

    # FIXME (2010-02-03): this is bad, we should do this as an alias_method_chain so we don't have
    # to pollute plugin code (and then lose it in an update)
    def process(iprot, oprot)
      name, type, seqid  = iprot.read_message_begin
      if respond_to?("process_#{name}")
         if defined?(Rails)
            Rails.logger.info { "Dispatching thrift call to #{name}" }
         end
         ms = [Benchmark.ms { send("process_#{name}", seqid, iprot, oprot) }, 0.01].max
         if defined?(Rails.logger)
            Rails.logger.info { "Dispatched thrift call to #{name} in %.0fms" % ms }
         end
        true
      else
        iprot.skip(Types::STRUCT)
        iprot.read_message_end
        x = ApplicationException.new(ApplicationException::UNKNOWN_METHOD, 'Unknown function '+name)
        oprot.write_message_begin(name, MessageTypes::EXCEPTION, seqid)
        x.write(oprot)
        oprot.write_message_end
        oprot.trans.flush
        false
      end
    end

    def read_args(iprot, args_class)
      args = args_class.new
      args.read(iprot)
      iprot.read_message_end
      args
    end

    def write_result(result, oprot, name, seqid)
      oprot.write_message_begin(name, MessageTypes::REPLY, seqid)
      result.write(oprot)
      oprot.write_message_end
      oprot.trans.flush
    end
  end
end
