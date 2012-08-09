# Whatever

SRCDIR  = ENV['SRCDIR']  || Dir.pwd
DESTDIR = ENV['DESTDIR'] || File.dirname(__FILE__)

task :default => ["#{DESTDIR}/src/facter", "#{DESTDIR}/src/puppet", "#{DESTDIR}/Rakefile"]

directory "#{DESTDIR}/src"

file "#{DESTDIR}/src/facter" do
  sh "git clone git://github.com/puppetlabs/facter src/facter -b 1.6.x"
end

file "#{DESTDIR}/src/puppet" do
  sh "git clone git://github.com/puppetlabs/puppet src/puppet -b 2.7.x"
end

file "#{DESTDIR}/Rakefile" do
  cp "#{SRCDIR}/Rakefile.ploy", "#{DESTDIR}/Rakefile"
end
