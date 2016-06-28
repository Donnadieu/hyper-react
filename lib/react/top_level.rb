require "native"
require 'active_support'
require 'react/component/base'

module React

  ATTRIBUTES = %w(accept acceptCharset accessKey action allowFullScreen allowTransparency alt
                  async autoComplete autoPlay cellPadding cellSpacing charSet checked classID
                  className cols colSpan content contentEditable contextMenu controls coords
                  crossOrigin data dateTime defer dir disabled download draggable encType form
                  formAction formEncType formMethod formNoValidate formTarget frameBorder height
                  hidden href hrefLang htmlFor httpEquiv icon id label lang list loop manifest
                  marginHeight marginWidth max maxLength media mediaGroup method min multiple
                  muted name noValidate open pattern placeholder poster preload radioGroup
                  readOnly rel required role rows rowSpan sandbox scope scrolling seamless
                  selected shape size sizes span spellCheck src srcDoc srcSet start step style
                  tabIndex target title type useMap value width wmode dangerouslySetInnerHTML)

  def self.create_element(type, properties = {}, &block)
    React::API.create_element(type, properties, &block)
  end

  def self.render(element, container)
    container = `container.$$class ? container[0] : container`
    if !(`typeof ReactDOM === 'undefined'`)
      component = Native(`ReactDOM.render(#{element.to_n}, container, function(){#{yield if block_given?}})`) # v0.15+
    elsif !(`typeof React.renderToString === 'undefined'`)
      component = Native(`React.render(#{element.to_n}, container, function(){#{yield if block_given?}})`)
    else
      raise "render is not defined.  In React >= v15 you must import it with ReactDOM"
    end

    component.class.include(React::Component::API)
    component
  end

  def self.is_valid_element(element)
    element.kind_of?(React::Element) && `React.isValidElement(#{element.to_n})`
  end

  def self.render_to_string(element)
    if !(`typeof ReactDOMServer === 'undefined'`)
      React::RenderingContext.build { `ReactDOMServer.renderToString(#{element.to_n})` } # v0.15+
    elsif !(`typeof React.renderToString === 'undefined'`)
      React::RenderingContext.build { `React.renderToString(#{element.to_n})` }
    else
      raise "renderToString is not defined.  In React >= v15 you must import it with ReactDOMServer"
    end
  end

  def self.render_to_static_markup(element)
    if !(`typeof ReactDOMServer === 'undefined'`)
      React::RenderingContext.build { `ReactDOMServer.renderToStaticMarkup(#{element.to_n})` } # v0.15+
    elsif !(`typeof React.renderToString === 'undefined'`)
      React::RenderingContext.build { `React.renderToStaticMarkup(#{element.to_n})` }
    else
      raise "renderToStaticMarkup is not defined.  In React >= v15 you must import it with ReactDOMServer"
    end
  end

  def self.unmount_component_at_node(node)
    if !(`typeof ReactDOM === 'undefined'`)
      `ReactDOM.unmountComponentAtNode(node.$$class ? node[0] : node)` # v0.15+
    elsif !(`typeof React.renderToString === 'undefined'`)
      `React.unmountComponentAtNode(node.$$class ? node[0] : node)`
    else
      raise "unmountComponentAtNode is not defined.  In React >= v15 you must import it with ReactDOM"
    end
  end

end

Element.instance_eval do
  def self.find(selector)
    selector = begin
      selector.dom_node
    rescue
      selector
    end if selector.respond_to? :dom_node
    `$(#{selector})`
  end

  def self.[](selector)
    find(selector)
  end

  define_method :render do |container = nil, params = {}, &block|
    klass = Class.new(React::Component::Base)
    klass.class_eval do
      render(container, params, &block)
    end
    React.render(React.create_element(klass), self)
  end
end if Object.const_defined?('Element')
