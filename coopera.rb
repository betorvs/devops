#!/usr/bin/env ruby

#
# versao 1.0
# roberto.scudeller at oi.net.br
#

require 'sensu-handler'
require 'json'

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
    post_data("Check\n#{incident_key}\nDescription\n#{description}")
  end

  def build_description
    [
      @event['check']['output'].strip,
      @event['client']['address'],
      @event['client']['subscriptions'].join(',')
    ].join(' : ')
  end

  def post_data(notice)
    uri = URI(coopera_webhook_url)

    if (defined?(coopera_proxy_addr)).nil?
      http = Net::HTTP.new(uri.host, uri.port)
    else
      http = Net::HTTP::Proxy(coopera_proxy_addr, coopera_proxy_port).new(uri.host, uri.port)
    end

    http.use_ssl = true

    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    text = notice
    req.body = payload(text).to_json

    response = http_response(req)
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
      "incident": {
        "description": [coopera_message_prefix, notice].compact.join(' '),
        "summary": incident_key
      }
    }
    #.tap do |payload|
    #  payload[:channel] = slack_channel if slack_channel
    #  payload[:username] = slack_bot_name if slack_bot_name
    #  payload[:attachments][0][:mrkdwn_in] = %w(text) if markdown_enabled
    #end
  end

    def check_status
    @event['check']['status']
  end
end
