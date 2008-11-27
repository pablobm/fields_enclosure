module FieldsEnclosure

  module FormHelperExt
    def self.included(base)
      base.module_eval do
        alias_method_chain :send, :bad_fields_log
        
        # Please somebody explain why I need to do this. (Otherwise, the method does not exist when called)
        alias_method :enclosure_method_temporarily_aliased, :enclosure
        alias_method :enclosure, :enclosure_method_temporarily_aliased
      end
    end
    
    def send_with_bad_fields_log(sym, *args, &block)
      method = args[1]
      options = args.find{|arg| arg.respond_to?('[]') && ! method.to_s.empty? && arg[:object].respond_to?(method.to_s)}
      object = options[:object] if options
      @enclosure_has_bad_fields = true if object && object.errors.on(method)
      send_without_bad_fields_log(sym, *args, &block)
    end

    def enclosure(enclosing_tag = 'div', options = {}, &proc)
      @enclosure_has_bad_fields = false
      enclosed_block = capture(&proc)
      output = ActionView::Base.enclosure_proc.call(self, enclosing_tag, enclosed_block, @enclosure_has_bad_fields, options)

      # Avoid deprecation warning from Rails 2.2      
      if FieldsEnclosure.must_specify_binding
        concat(output, proc.binding)
      else
        concat(output)
      end
    end
  end
  
  module FormBuilderExt
    def enclosure(*args, &block)
      @template.send(:enclosure, *args, &block)
    end
  end
  
  module ActionViewBaseExt
    def self.included(base)
      base.class_eval do
        @@enclosure_proc = Proc.new do |template, enclosing_html_tag, enclosed_html, has_errors, options|
          options[:class] = options[:class] ? (options[:class] + ' containsErrors') : 'containsErrors' if has_errors
          template.content_tag(enclosing_html_tag, enclosed_html, options)
        end
        cattr_accessor :enclosure_proc
      end
    end
  end
  
  
  private
  
  def self.must_specify_binding
    (ActionPack::VERSION::STRING.split('.') <=> '2.2'.split('.')) < 0
  end
    
end

