use_inline_resources if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11')

action :create do 
  Chef::Log.info "creating knife file #{@new_resource.name}"

  directory "#{node['jenkins']['server']['home']}/.chef" do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0755
  end

  knife_path = "#{node['jenkins']['server']['home']}/.chef"

  # user.pem
  file "#{knife_path}/#{new_resource.chef_node_name}.pem" do
    content new_resource.client_key
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    action :create
  end

  # validation.pem
  file "#{knife_path}/#{new_resource.validation_client_name}.pem" do
    content new_resource.validation_key
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    action :create
  end

  # knife config
  template "#{knife_path}/#{new_resource.name}.rb" do
    source "knife.rb.erb"
    cookbook 'pipeline'
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    variables(
      :chef_server_url        => new_resource.chef_server_url,
      :validation_client_name => new_resource.validation_client_name,
      :chef_node_name         => new_resource.chef_node_name,
      :validation_key_path    => ::File.join(knife_path, "#{new_resource.validation_client_name}.pem"),
      :client_key_path        => ::File.join(knife_path, "#{new_resource.chef_node_name}.pem"),
      :providers              => new_resource.providers
    )
  end
end
