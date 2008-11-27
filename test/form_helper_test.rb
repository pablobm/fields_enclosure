require 'test_helper'

silence_warnings do
  ACCOUNT_FIELDS = [:holder_name, :number, :sort_code1, :sort_code2, :sort_code3]
  Account = Struct.new(*ACCOUNT_FIELDS)
  Account.class_eval do
    ACCOUNT_FIELDS.each do |field|
      alias_method "#{field}_before_type_cast".to_sym, field.to_sym unless respond_to?("#{field}_before_type_cast".to_sym)
    end

    def new_record=(boolean)
      @new_record = boolean
    end

    def new_record?
      @new_record
    end
  end
end

class FormHelperTest < ActionView::TestCase
  tests ActionView::Helpers::FormHelper

  def setup
    @account = Account.new
    def @account.errors()
      Class.new{
        def on(field); "can't be empty" if field.to_s == "sort_code2"; end
        def empty?() false end
        def count() 1 end
        def full_messages() [ "Author name can't be empty" ] end
      }.new
    end
    def @account.id; 123; end
    def @account.id_before_type_cast; 123; end
    def @account.to_param; '123'; end

    @account.holder_name = "John Doe"
    @account.number      = 12345678
    @account.sort_code1  = 12
    @account.sort_code2  = 34
    @account.sort_code3  = 56

    @controller = Class.new do
      attr_reader :url_for_options
      def url_for(options)
        @url_for_options = options
        "http://www.example.com"
      end
    end
    @controller = @controller.new
  end
    
  def test_form_for
    _erbout = ''
  
    form_for(:account, @account, :html => { :id => 'create-account' }) do |f|
      f.enclosure(:p){ _erbout.concat f.text_field(:holder_name)}
      f.enclosure(:p){ _erbout.concat f.text_field(:number)}
      f.enclosure(:p, :class => 'sort_code_triplet') do
        _erbout.concat f.text_field(:sort_code1)
        _erbout.concat f.text_field(:sort_code2)
        _erbout.concat f.text_field(:sort_code3)
      end
      f.enclosure(:p){ _erbout.concat f.submit('Save account details')}
    end
  
    expected =
      "<form action='http://www.example.com' id='create-account' method='post'>" +
        "<p><input name='account[holder_name]' size='30' type='text' id='account_holder_name' value='John Doe' /></p>" +
        "<p><input name='account[number]' size='30' type='text' id='account_number' value='12345678' /></p>" +
        "<p class='sort_code_triplet containsErrors'>" +
          "<input name='account[sort_code1]' size='30' type='text' id='account_sort_code1' value='12' />" +
          "<div class='fieldWithErrors'><input name='account[sort_code2]' size='30' type='text' id='account_sort_code2' value='34' /></div>" +
          "<input name='account[sort_code3]' size='30' type='text' id='account_sort_code3' value='56' />" +
        "</p>" +
        "<p><input name='commit' id='account_submit' type='submit' value='Save account details' /></p>" +
      "</form>"
  
    assert_dom_equal expected, _erbout
  end
  
  
  protected
  
  def protect_against_forgery?
    false
  end
end
