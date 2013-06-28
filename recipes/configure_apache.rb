# Configures an Apache vhost for accessing the Confluence installation


include_recipe "apache2"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_ajp"
include_recipe "apache2::mod_ssl"

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

#apache_site "confluence.conf"
