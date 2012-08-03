#!/usr/bin/env ruby

require 'optparse'

options = {
  # We can't load these until we have :basedir set correctly
  #:certname => Facter.value('sp_serial_number'),
  #:server   => 'puppet.' + Facter.value('domain'),
  :basedir  => File.expand_path(File.dirname(__FILE__)),
}

opts = OptionParser.new do |opt|

  opt.banner = "Usage: #{File.basename($0)} [--certname NAME] [--server NAME] [--basedir DIRECTORY]"
  opt.separator ""

  opt.on('--certname=val', "The certificate name to use when generating a CSR.",
                           "Default: the OSX install UUID") do |certname|
    options[:certname] = certname
  end

  opt.on('--server=val', "The puppetmaster to connect to.",
                         "Default: puppet.domainname") do |server|
    options[:server] = server
  end

  opt.on('--basedir', "The directory containing the Facter and Puppet source.",
                       "Default: The directory containing this file (#{options[:basedir]})") do |basedir|
    options[:basedir] = basedir
  end

  opt.on('--installdir', "The directory to install puppet into",
                       "Default: The directory containing this file (#{options[:basedir]})") do |basedir|
    options[:basedir] = basedir
  end

  opt.on('--noop', "Only print the command to be executed") do
    options[:noop] = true
  end

  opt.on('-h', '--help', 'Display this help.') do
    puts opts
    exit 1
  end
end

begin
  opts.parse!
rescue => e
  $stderr.puts e
  exit 1
end

unless options[:installdir]
  $stderr.puts 'installdir not specified'
  exit 1
end

begin
  basedir = options[:basedir]

  $LOAD_PATH << "#{basedir}/src/facter/lib"
  require 'facter'
  Facter.loadfacts

  server   = (options[:server]   || "puppet." + Facter.value(:domain))
  certname = (options[:certname] || Facter.value(:sp_platform_uuid).downcase)

  interpreter = "ruby -I#{basedir}/src/facter/lib -I#{basedir}/src/puppet/lib"
  cmd         = "#{basedir}/src/puppet/bin/puppet"
  args        = "agent -t --waitforcert 1 --pluginsync"
  args       << " --server #{server}"
  args       << " --certname #{certname}"
  args       << " --confdir #{installdir}/etc/puppet"
  args       << " --vardir #{installdir}/var/lib/puppet"

  full = "#{interpreter} #{cmd} #{args}"

  if options[:noop]
    puts full
  else
    Kernel.exec full
  end

rescue LoadError => e
  $stderr.puts "Failed while trying to load dependency: #{e}"
  $stderr.puts "(Is basedir set correctly?)"
  exit 1
rescue => e
  $stderr.puts e
  $stderr.puts e.backtrace
  exit 1
end

__END__

certname=$1

if [ -z "$certname"]; then
  echo "Usage: $0 certname"
  exit 1
fi

basedir=`dirname $0`
puppet="${basedir}/puppet/bin/puppet"

RUBYLIB="${basedir}/facter:${basedir}/puppet"
export RUBYLIB



$puppet --certname $certname
