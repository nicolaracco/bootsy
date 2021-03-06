module Bootsy
  # Public: Module to include Bootsy in `ActionView::Base`.
  module FormHelper
    # Public: Return a textarea element with proper attributes to
    # be loaded as a WYSIWYG editor.
    #
    # object_name - The String or Symbol identifier of the object assigned
    #               to the template.
    #
    # method      - The Symbol attribute name on the object assigned to the
    #               form builder that will tailor the editor.
    #
    # options     - The Hash of options used to enable/disable features of
    #               the editor (default: {}):
    #               :container      - The `Bootsy::Container` instance model that
    #                                 will be referenced by the editor's image
    #                                 gallery. Defaults to the object assigned to
    #                                 the template, if it is a `Container`.
    #               :uploader       - The Boolean value used to enable/disable the
    #                                 image upload feature. Default: true, if a
    #                                 `Container` is found. false otherwise.
    #               :editor_options - The Hash of options with Boolean values used
    #                                 to enable/disable features of the editor.
    #                                 Available options are described in the Bootsy
    #                                 initializer file (which is the default for
    #                                 this argument).
    def bootsy_area(object_name, method, options = {})
      container = options[:container] || options[:object]

      output = self.text_area(object_name, method, text_area_options(options))

      if output.present? && enable_uploader?(options)
        container.bootsy_image_gallery_id ||= Bootsy::ImageGallery.create!.id

        output += self.render('bootsy/images/modal', container: container)

        if container.new_record?
          output += self.hidden_field(object_name, :bootsy_image_gallery_id, class: 'bootsy_image_gallery_id')
        end
      end

      output
    end

    private

    def enable_uploader?(options)
      if options[:uploader] == false
        false
      elsif options[:container].is_a?(Container)
        true
      elsif options[:container].blank? && options[:object].is_a?(Container)
        true
      else
        false
      end
    end

    def tag_class(options)
      classes = if options[:class].blank?
        []
      elsif options[:class].kind_of?(Array)
        options[:class]
      else
        [options[:class]]
      end

      classes << 'bootsy_text_area'
    end

    def data_options(options)
      (options[:data] || {}).merge Hash[ bootsy_options(options).map { |k,v| ["bootsy-#{k}", v] } ]
    end

    def bootsy_options(options)
      Bootsy.editor_options.
        merge(options[:editor_options] || {}).
        merge(uploader: enable_uploader?(options))
    end

    def text_area_options(options)
      options.except(
        :container,
        :uploader,
        :editor_options
      ).merge(
        data: data_options(options),
        class: tag_class(options)
      )
    end
  end
end
