# Whatever

task :default => ['src/facter', 'src/puppet', 'install-puppet.rb', 'Rakefile']

directory 'src'

file 'src/facter' do
  sh "git clone git://github.com/puppetlabs/facter src/facter -b 1.6.x"
end

file 'src/puppet' do
  sh "git clone git://github.com/puppetlabs/puppet src/puppet -b 2.7.x"
end

file "install-puppet.rb" do
  cp "#{File.dirname(__FILE__)}/install-puppet.rb", '.'
  chmod 0755, "install-puppet.rb"
end

file "Rakefile" do
  cp "#{File.dirname(__FILE__)}/Rakefile.ploy", 'Rakefile'
end
