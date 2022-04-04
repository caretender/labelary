module Labelary
  class Label
    def self.render(*args)
      new(*args).render
    end

    def initialize(zpl, args = {})
      @zpl    ||= zpl
      @dpmm   ||= args[:dpmm] || config.dpmm
      @width  ||= args[:width] || config.width
      @height ||= args[:height] || config.height
      @index  ||= args[:index] || config.index
      @content_type ||= args[:content_type] || config.content_type
      @font ||= args[:font] || config.font

      raise 'Invalid dpmm'   if @dpmm.nil?
      raise 'Invalid width'  if @width.nil?
      raise 'Invalid height' if @height.nil?
    end

    # http://labelary.com/service.html
    def render
      payload = font_string + @zpl
      response = Labelary::Client.connection.post "/v1/printers/#{@dpmm}dpmm/labels/#{@width}x#{@height}/#{@index}/",
                                                  payload, { Accept: @content_type }
      response.body
    end

    def font_string
      @font.present? ? @font.to_s : ''
    end

    private

    def config
      @config ||= Labelary.configuration
    end
  end
end
