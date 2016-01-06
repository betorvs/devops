#! /usr/bin/env ruby
#
# check-puppet-environment
#
# DESCRIPTION:
#   Check the puppet agent environment was run
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   Critical if run into environment different than production
#
#   check-puppet-last-run --summary-file /opt/puppetlabs/puppet/cache/state/last_run_report.yaml --environment production
#
# NOTES:
#
# LICENSE:
#

require 'sensu-plugin/check/cli'
require 'yaml'
require 'time'

class PuppetEnvironmentRun < Sensu::Plugin::Check::CLI
  option :report_file,
         short:       '-r PATH',
         long:        '--report-file PATH',
         default:     '/opt/puppetlabs/puppet/cache/state/last_run_report.yaml',
         description: 'Location of last_run_report.yaml file'

  option :environment,
         short:       '-e N',
         long:        '--environment production',
         default:     'production',
         description: 'The environment default for all servers'

  def run

    if !File.exists?(config[:report_file])
      unknown "File #{config[:report_file]} not found"
    end

    begin
      #summary = YAML.load_file(config[:report_file])
      out_file = File.open("/tmp/report.txt","w")
      out_file.puts("---")
      File.open(config[:report_file]).to_a.reverse.each_with_index { |line, index| out_file << line if index < 9 }
      out_file.close
      summary = YAML.load_file("/tmp/report.txt")
      @env = summary['environment']
    rescue
      unknown "Could not process #{config[:report_file]}"
    end

    @message = "Puppet Agent run into this environment = #{@env}"

    File.delete("/tmp/report.txt")
    if @env != config[:environment]
      critical @message 
    else
      ok @message 
    end

  end
end
