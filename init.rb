require 'action_pack'      # Needed to sniff the version number
require 'fields_enclosure'

ActionView::Helpers::FormBuilder.send :include, FieldsEnclosure::FormBuilderExt
ActionView::Helpers::FormHelper.send :include, FieldsEnclosure::FormHelperExt
ActionView::Base.send :include, FieldsEnclosure::ActionViewBaseExt
