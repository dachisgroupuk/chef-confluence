#
# Cookbook Name:: confluence
# Attributes:: confluence
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
override[:apache][:mpm] = "worker"


default[:confluence][:virtual_host_name]  = "confluence.#{domain}"
default[:confluence][:virtual_host_alias] = "confluence.#{domain}"
#
# HTTP Auth attributes, which if set will protect the site.
default[:confluence][:http_user] 	= "confluence"
default[:confluence][:http_password] 	= "confluence"
# type-version-standalone
default[:confluence][:version]           = "3.4.8"
default[:confluence][:install_path]      = "/srv/confluence"
default[:confluence][:home_directory]    = "/srv/confluence-data"
default[:confluence][:run_user]          = "www-data"
default[:confluence][:database]          = "mysql"
default[:confluence][:database_host]     = "localhost"
default[:confluence][:database_user]     = "confluence"
default[:confluence][:database_password] = "change_me"
default[:confluence][:server_port]       = "8000"
default[:confluence][:http_port]         = "8080"
default[:confluence][:ajp_port]          = "8009"
#
# SSL Configuration
# If these are not initialised by a role or node, then the SSL conifguration will
# not be written out in the Apache config
#
default[:confluence][:ssl_key] = ""
default[:confluence][:ssl_cert] = ""
default[:confluence][:ssl_intermediate_cert] = ""
#
# Location of custom resources (e.g. for use with custom themes)
default[:confluence][:resources_dir]    = "#{node[:confluence][:install_path]}/confluence/resources"
#
# JVM Parameters
#
# -Xms
default[:confluence][:initial_heap_size] = "256"
# -Xmx
default[:confluence][:max_heap_size] = "512"
# -XX:MaxPermSize
default[:confluence][:max_permanent_heap] = "256"

