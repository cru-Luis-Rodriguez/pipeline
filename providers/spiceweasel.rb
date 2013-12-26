use_inline_resources if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11')

action :create do 
  gem_package 'spiceweasel' do
    gem_binary('/opt/chef/embedded/bin/gem')
  end

  spiceweasel_job_name = new_resource.name

  spiceweasel_job_config = File.join(node['jenkins']['node']['home'], "#{spiceweasel_job_name}-config.xml")

  jenkins_job spiceweasel_job_name do
    action :nothing
    config spiceweasel_job_config
  end

  template spiceweasel_job_config do
    source    'spiceweasel-config.xml.erb'
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 0644
    variables({
      :repository => new_resource.repository,
      :branch => new_resource.branch,
      :file => new_resource.file
    })
    notifies  :update, resources(:jenkins_job => spiceweasel_job_name), :immediately
    notifies  :build, resources(:jenkins_job => spiceweasel_job_name), :immediately
  end
end