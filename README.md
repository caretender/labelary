# Labelary

[![Gem Version](https://badge.fury.io/rb/labelary.svg)](https://badge.fury.io/rb/labelary)

Labelary ZPL (Zebra Printer Language) Web Service API Client for Ruby.

**Features:**

* Render ZPL strings as PNG or PDF.
* Encode images to ZPL.
* Global configuration or per-request.

Web service details and instructions: http://labelary.com/service.html

Supported ZPL commands: http://labelary.com/docs.html


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'labelary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install labelary

## Configuration

Configuration is available, you can set this per request or in an initializer like so:

```ruby
# config/initializers/labelary.rb
Labelary.configure do |config|
  config.dpmm   = 8 # required
  config.width  = 3.98 # required (inches)
  config.height = 6.85 # required (inches)
  config.index = 0 # optional, for picking a label when multiple are present in the ZPL (usually 0)
  config.content_type = 'image/png' # or 'application/pdf', specifies the content type of the returned label
  config.url = 'http://api.labelary.com' # optional (for self hosted)
end
```

## Usage

### Rendering Labels

Pass in a `width`, `height`, `dpmm` (or set defaults in your configuration block) and a ZPL string to have it rendered as a PNG or PDF.

```ruby
Labelary::Label.render zpl: '^XA^FDHello World^FS^XZ', content_type: 'image/png', dpmm: 8, width: 6, height: 4
#> PNG blob
```

Or with configuration:

```ruby
# config/initializers/labelary.rb
Labelary.configure do |config|
  config.dpmm   = 8
  config.width  = 6
  config.height = 4
  config.content_type = 'application/pdf'
end

# elsewhere e.g. lib/label_render.rb
Labelary::Label.render zpl: '^XA^FDHello World^FS^XZ'
#> PDF blob
```

### ZPL Encoding Images

Pass in an image (or an IO object) and it's mime type and you'll get back a ZPL encoded version.

```ruby
Labelary::Image.encode path: '/path/to/image.png', mime_type: 'image/png'
#> "^GFA,6699,6699,87,,::lR01F,SNIP,:^FS"

Labelary::Image.encode file_io: IO.read('/path/to/image.png'), filename: 'image.png', mime_type: 'image/png'
#> "^GFA,6699,6699,87,,::lR01F,SNIP,:^FS"
```

### Rails Example

It's reasonably straight-forward to incorporate this into a Rails project if you wish. Here's an example in a controller:

```ruby
# config/initializers/labelary.rb
Labelary.configure do |config|
  config.dpmm   = 8
  config.width  = 6
  config.height = 4
end

# config/initializers/mime_types.rb
Mime::Type.register 'text/plain', :zpl
```

```
# app/views/labels/label.zpl.erb
^XA^FDHello <%= @label.name_for_earth %>^FS^XZ
```

```ruby
# app/controllers/labels_controller.rb
class LabelsController < ApplicationController

  # snip

  def label
    @label = Label.find params[:id]
    zpl_string = render_to_string formats: [:zpl]

    respond_to do |format|
      format.zpl
      format.png { get_rendered_zpl zpl_string }
      format.pdf { get_rendered_zpl zpl_string, 'application/pdf' }
    end
  end

  private

  def get_rendered_zpl(zpl_string, content_type='image/png')
    rendered_zpl = Labelary::Label.render zpl: zpl_string, content_type: content_type
    send_data rendered_zpl, type: content_type, disposition: 'inline'
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rjocoleman/labelary.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
