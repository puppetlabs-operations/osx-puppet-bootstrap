#!/usr/bin/env ruby

require 'optparse'

options = {
  # We can't load these until we have :basedir set correctly
  #:certname => Facter.value('sp_serial_number'),
  #:server   => 'puppet.' + Facter.value('domain'),
  :basedir  => File.expand_path(File.dirname(__FILE__)),
}

opts = OptionParser.new do |opt|

  opt.banner = "Usage: #{$0} [--certname NAME] [--server NAME] [--basedir DIRECTORY]"
  opt.separator ""

  opt.on('--certname=val', "The certificate name to use when generating a CSR.",
                           "Default: the OSX serial number") do |certname|
    options[:certname] = certname
  end

  opt.on('--server=val', "The puppetmaster to connect to.",
                         "Default: puppet.domainname") do |server|
    options[:certname] = certname
  end

  opt.on('--basedir', "The directory containing the Facter and Puppet source.",
                       "Default: The directory containing this file (#{options[:basedir]})") do |basedir|
    options[:basedir] = basedir
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


#WELL WOULDN'T IT BE FUCKING NICE IF FACES WERE ACTUALLY FUCKING FUNCTIONAL IN
#THE SLIGHTEST CAPACITY. FUCK

$LOADPATH << File.join(options[:basedir], 'facter', 'lib')
#$LOADPATH << File.join(options[:basedir], 'puppet', 'lib')

begin
  require 'facter'

  Facter.loadfacts

  options[:server]     ||= "puppet." + Facter.value(:domain)
  options[:certname]   ||= Facter.value(:certname)

  ENV['RUBYLIB'] = "#{basedir}/facter/lib:#{basedir}/puppet/lib"
  #Kernel.exec %{#{basedir}/puppet/bin/puppet agent -t --waitforcert 1 --server #{options[:server]} --certname #{options[:certname]}}
  puts %{#{basedir}/puppet/bin/puppet agent -t --waitforcert 1 --server #{options[:server]} --certname #{options[:certname]}}

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



ruby $puppet --certname 
