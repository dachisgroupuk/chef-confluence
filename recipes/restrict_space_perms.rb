# Removes "registered users" view privileges from newly created
# spaces. Helps prevent data being accessed by those not meant to
# see it.

bash "remove-registered-users-space-permissions" do
  code "sed -i '/permissionSetter.registeredCanView/s/\#/# # /g' #{node['confluence']['install_path']}/confluence/spaces/includes/createspace_permissions.vm"
  not_if "grep permissionSetter.registeredCanView #{node['confluence']['install_path']}/confluence/spaces/includes/createspace_permissions.vm |grep '# # tag'"
end

