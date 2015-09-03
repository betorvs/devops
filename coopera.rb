#!/usr/bin/env ruby

#
# versao 1.0
# roberto.scudeller at oi.net.br
#

require 'sensu-handler'
require 'json'
require 'openssl'

class Coopera < Sensu::Handler
  option :json_config,
    description: 'Configuration name',
    short: '-j JSONCONFIG',
    long: '--json JSONCONFIG',
    default: 'coopera'

  def coopera_webhook_url
    get_setting('webhook_url')
  end 

  def coopera_channel
    get_setting('channel')
  end

  def coopera_proxy_addr
    get_setting('proxxy_addr')
  end

  def coopera_proxy_port
    get_setting('proxy_port')
  end

  def coopera_message_prefix
    get_setting('message_prefix')
  end

  def incident_key
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def get_setting(name)
    settings[config[:json_config]][name]
  end

  def handle
    description = @event['check']['notification'] || build_description
    post_data("Check #{incident_key} Description #{description}")
  end

  def build_description
    [
      @event['check']['output'].strip,
      @event['client']['address'],
      @event['client']['subscriptions'].join(' ')
    ].join(' ')
  end

  def post_data(notice)
    uri = URI(coopera_webhook_url)

    if (defined?(coopera_proxy_addr)).nil?
      http = Net::HTTP.new(uri.host, uri.port)
    else
      http = Net::HTTP::Proxy(coopera_proxy_addr, coopera_proxy_port).new(uri.host, uri.port)
    end

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", initheader = {'Content-Type' =>'application/json'})

    text = notice
    req.body = payload(text).to_json
    puts req.body
    response = http.request(req)
    verify_response(response)
  end

  def verify_response(response)
    case response
    when Net::HTTPSuccess
      true
    else
      fail response.error!
    end
  end

  def payload(notice)
    {
      "incident"=> {
        "description"=> [coopera_message_prefix, notice].compact.join(' '),
        "summary"=> incident_key
      }
    }
  end

    def check_status
    @event['check']['status']
  end
end
