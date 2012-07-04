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
    options[:server] = server
  end

  opt.on('--basedir', "The directory containing the Facter and Puppet source.",
                       "Default: The directory containing this file (#{options[:basedir]})") do |basedir|
    options[:basedir] = basedir
  end

  opt.on('--noop', "Only print the command to be exec'd") do
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


#WELL WOULDN'T IT BE FUCKING NICE IF FACES WERE ACTUALLY FUCKING FUNCTIONAL IN
#THE SLIGHTEST CAPACITY. FUCK

$LOAD_PATH << File.join(options[:basedir], 'src', 'facter', 'lib')
#$LOADPATH << File.join(options[:basedir], 'src', 'puppet', 'lib')

begin
  require 'facter'

  Facter.loadfacts

  basedir = options[:basedir]

  options[:server]     ||= "puppet." + Facter.value(:domain)
  options[:certname]   ||= Facter.value(:sp_serial_number).downcase

  ENV['RUBYLIB'] = "#{basedir}/facter/lib:#{basedir}/puppet/lib"
  interp = %{ruby -I#{basedir}/src/facter/lib -I#{basedir}/src/puppet/lib}
  cmd  = "#{basedir}/src/puppet/bin/puppet"
  args = %{agent -t --waitforcert 1 --server #{options[:server]} --certname #{options[:certname]}}

  full = [interp, cmd, args].flatten.join ' '

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
