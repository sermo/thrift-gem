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

# don't attempt to build the native extensions on platforms that match the
# following regular expression
if `uname -a` =~ /Darwin|Debian|Ubuntu/
  # The following is adapted from:
  # http://stackoverflow.com/questions/17406246/native-extensions-fallback-to-pure-ruby-if-not-supported-on-gem-install
  # Create a dummy Makefile, to satisfy Gem::Installer#install
  File.open("Makefile", "wb") do |f|
    f.puts <<-MAKEFILE
.PHONY: install
install:
\t@echo "Extensions not installed, falling back to pure Ruby version."
  MAKEFILE
  end
else
  require 'mkmf'
  $CFLAGS = "-g -O2 -Wall -Werror"
  have_func("strlcpy", "string.h")
  create_makefile 'thrift_native'
end

