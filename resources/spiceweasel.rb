
actions :create
default_action :create

attribute :chef_server, :kind_of => Hash, :default => {}

attribute :file, :kind_of => String
attribute :repository, :kind_of => String
attribute :branch, :kind_of => String

def initialize(*args)
  super
  @action = :create
end