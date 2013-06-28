#
# Cookbook Name:: confluence
# Recipe:: default
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

#
# Manual Steps!
#
# MySQL:
#
#   create database confluencedb character set utf8;
#   grant all privileges on confluencedb.* to '$confluence_user'@'localhost' identified by '$confluence_password';
#   flush privileges;

#include_recipe "runit"
# need to check this
include_recipe "java::sunjdk1.6"
include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_ajp"

nofile_limit "java" do
  limit 8192
end

directory "#{node[:confluence][:install_path]}" do
  recursive true
  owner "java"
  #owner "www-data" # this should be owned by java for us
end

remote_file "confluence" do
  path "/tmp/confluence.tar.gz"
  if node['confluence']['version'].start_with?('4')
    source "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-#{node['confluence']['version']}.tar.gz"
  else
    source "http://www.atlassian.com/software/confluence/downloads/binary/confluence-#{node['confluence']['version']}-std.tar.gz"
  end
  not_if do
    File.exists?("/tmp/confluence.tar.gz")
  end
end

bash "untar-confluence" do
  code "(cd /tmp; tar zxvf /tmp/confluence.tar.gz --strip-component 1 -C #{node['confluence']['install_path']})"
  not_if do
    File.exists?("#{node['confluence']['install_path']}/bin/startup.sh")
  end
end


cookbook_file "#{node[:confluence][:install_path]}/bin/startup.sh" do
  source "startup.sh"
  mode 0755
end
  
template "#{node[:confluence][:install_path]}/bin/catalina.sh" do
  source "catalina.sh.erb"
  mode 0755
end

template "#{node[:confluence][:install_path]}/bin/setenv.sh" do
  source "setenv.sh.erb"
  mode 0755
end

template "#{node[:confluence][:install_path]}/conf/server.xml" do
  source "server.xml.erb"
  mode 0644
end
 
# tell confluence where the home directories are:
template "#{node[:confluence][:install_path]}/confluence/WEB-INF/classes/confluence-init.properties" do
  source "confluence-init.properties.erb"
  mode 0755
end

# Create the data/home directory
directory "#{node[:confluence][:home_directory]}" do
  action :create
  recursive true
  owner "java"
  if node['recipes'].index('users::deploy_user') != nil || node['recipes'].index('users::devs') != nil
    group "devs"
  else
    group "java"
  end
  mode 0775
end

# The above directory block does not ensure that the entire directory structure is owned
# by "java", so a code block is required:
script "fix_ownership" do
  interpreter "bash"
  user "root"
  if node['recipes'].index('users::deploy_user') != nil || node['recipes'].index('users::devs') != nil
    code "chown -R java:devs #{node[:confluence][:install_path]} #{node[:confluence][:home_directory]}"
  else
    code "chown -R java:java #{node[:confluence][:install_path]} #{node[:confluence][:home_directory]}"
  end
end

# Now to recursively chmod the directory
bash "fix_permissions" do
  user "root"
  code "chmod -R g+wX #{node[:confluence][:install_path]} #{node[:confluence][:home_directory]}"
end

# Create/update init.d script
template "/etc/init.d/confluence" do
  source "confluence.init.d.erb"
  owner "root"
  group "root"
  mode 00755
  only_if do
    node[:platform] == "centos" || node[:platform] == "redhat" || node[:platform] == "rhel" || node[:platform] == "fedora"
  end
end

service "confluence" do
  action [ :enable, :start ]
end

# If the HTTP Auth attributes are set, we need to generate a htpassd file
if node[:confluence][:http_user] != "" && node[:confluence][:http_password] != ""

  # Decide if we need to "create" the htpasswd file or not
  if FileTest.exists?("/etc/httpd/conf.d/#{node[:confluence][:virtual_host_name]}.htpasswd")
    script "generate_htpasswd" do
      interpreter "bash"
      user "root"
      code "/usr/bin/htpasswd -b /etc/httpd/conf.d/#{node[:confluence][:virtual_host_name]}.htpasswd #{node[:confluence][:http_user]} #{node[:confluence][:http_password]}"
    end
  else
    script "generate_htpasswd" do
      interpreter "bash"
      user "root"
      code "/usr/bin/htpasswd -bc /etc/httpd/conf.d/#{node[:confluence][:virtual_host_name]}.htpasswd #{node[:confluence][:http_user]} #{node[:confluence][:http_password]}"
    end
  end
end

# we need to make this fit our naming approach, ideally with a named site.name.conf file
#template "#{node[:apache][:dir]}/sites-available/confluence.conf" do
#  source "apache.conf.erb"
#  mode 0644
#end

web_app "#{node['confluence']['virtual_host_name']}.confluence" do
  server_name node['confluence']['virtual_host_name']
  template "apache.conf.erb"
end
