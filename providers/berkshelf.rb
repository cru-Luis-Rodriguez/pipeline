use_inline_resources if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11')

action :create do 
  Chef::Log.info "creating berkshelf config #{@new_resource.name}"

  gem_package "berkshelf" do
    gem_binary("/opt/chef/embedded/bin/gem")
    version "2.0.10"
  end

  # create berkshelf
  directory "#{node['jenkins']['server']['home']}/.berkshelf" do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0755
  end

  berkshelf_path = "#{node['jenkins']['server']['home']}/.berkshelf"

  # user.pem
  file "#{berkshelf_path}/#{new_resource.chef_node_name}.pem" do
    content new_resource.client_key
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    action :create
  end

  # validation.pem
  file "#{berkshelf_path}/#{new_resource.validation_client_name}.pem" do
    content new_resource.validation_key
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    action :create
  end

  # berkshelf config
  template "#{berkshelf_path}/#{new_resource.name}-config.json" do
    source "config.json.erb"
    cookbook 'pipeline'
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    variables(
      :chef_server_url        => new_resource.chef_server_url,
      :validation_client_name => new_resource.validation_client_name,
      :chef_node_name         => new_resource.chef_node_name,
      :validation_key_path    => ::File.join(berkshelf_path, "#{new_resource.validation_client_name}.pem"),
      :client_key_path        => ::File.join(berkshelf_path, "#{new_resource.chef_node_name}.pem"),
    )
  end
end
