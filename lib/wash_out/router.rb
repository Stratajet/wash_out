require 'nori'

module WashOut
  # This class is a Rack middleware used to route SOAP requests to a proper
  # action of a given SOAP controller.
  class Router
    def initialize(controller_name)
      @controller_name = "#{controller_name.to_s}_controller".camelize
    end

    def controller
      @controller
    end

    def parse_soap_action(env)
      return env['wash_out.soap_action'] if env['wash_out.soap_action']

      soap_action = controller.soap_config.soap_action_routing ? env['HTTP_SOAPACTION'].to_s.gsub(/^"(.*)"$/, '\1')
                                                               : ''

      if soap_action.blank?
        parsed_soap_body = nori(controller.soap_config.snakecase_input).parse(soap_body env)
        return nil if parsed_soap_body.blank?

        soap_action = parsed_soap_body
            .values_at(:envelope, :Envelope).compact.first
            .values_at(:body, :Body).compact.first
            .keys.first.to_s
      end

      # RUBY18 1.8 does not have force_encoding.
      soap_action.force_encoding('UTF-8') if soap_action.respond_to? :force_encoding

      if controller.soap_config.namespace
        namespace = Regexp.escape controller.soap_config.namespace.to_s
        soap_action.gsub!(/^(#{namespace}(\/|#)?)?([^"]*)$/, '\3')
      end

      env['wash_out.soap_action'] = soap_action
    end

    def nori(snakecase=false)
      Nori.new(
        :parser => controller.soap_config.parser,
        :strip_namespaces => true,
        :advanced_typecasting => true,
        :convert_tags_to => (
          snakecase ? lambda { |tag| tag.snakecase.to_sym }
                    : lambda { |tag| tag.to_sym }
        )
      )
    end

    def soap_body(env)
      # Don't let nobody intercept us ^_^
      env['rack.input'].rewind if env['rack.input'].respond_to?(:rewind)

      env['rack.input'].respond_to?(:string) ? env['rack.input'].string
                                             : env['rack.input'].read
    end

    def parse_soap_parameters(env)
      return env['wash_out.soap_data'] if env['wash_out.soap_data']

      env['wash_out.soap_data'] = nori(controller.soap_config.snakecase_input).parse(soap_body env)

      # deal with referenced arrays
      WashOut::Dispatcher.process_referenced_arrays_objects(env['wash_out.soap_data'])

      references = WashOut::Dispatcher.deep_select_for_ids_and_arrays(env['wash_out.soap_data'])

      unless references.blank?
        replaces = {}; references.each{|r| replaces['#'+r[:@id]] = r}
        env['wash_out.soap_data'] = WashOut::Dispatcher.deep_replace_href(env['wash_out.soap_data'], replaces)
      end

      env['wash_out.soap_data']
    end

    def call(env)
      @controller = @controller_name.constantize

      soap_action     = parse_soap_action(env)
      return [200, {}, ['OK']] if soap_action.blank?

      soap_parameters = parse_soap_parameters(env)

      action_spec = controller.soap_actions[soap_action]

      if action_spec
        action = action_spec[:to]
      else
        action = '_invalid_action'
      end

      controller.action(action).call(env)
    end
  end
end
