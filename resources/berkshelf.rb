
actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :chef_server_url, :kind_of => String
attribute :validation_client_name, :kind_of => String
attribute :chef_node_name, :kind_of => String, :default => node['jenkins']['server']['user']
attribute :validation_key, :kind_of => String
attribute :client_key, :kind_of => String

attribute :repository, :kind_of => String
attribute :branch, :kind_of => String

def initialize(*args)
  super
  @action = :create
end
