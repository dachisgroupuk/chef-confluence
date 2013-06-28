#
# Cookbook Name:: confluence
# Recipe:: custom_resources 
#
# Copyright 2008-2009, Headshift Ltd.
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
# Creates a specific directory in the Confluence application for custom
# dectorators/resources.

include_recipe "confluence"

directory "#{node[:confluence][:resources_dir]}" do
  owner "java"
  group "devs"
  mode 0775
end
 
