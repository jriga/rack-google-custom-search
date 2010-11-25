require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rack::GoogleCustomSearch" do
  before { @midddleware = Rack::GoogleCustomSearch.new(nil, {}) }

  it "should add autocompletion when set to true" do
    expected = <<-EOF
<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1');
  google.setOnLoadCallback(function() {
    var customSearchControl = new google.search.CustomSearchControl('token');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    var options = new google.search.DrawOptions();
    options.setAutoComplete(true);
    customSearchControl.draw('css_id', options);
  }, true);
</script>
EOF
    
    actual_result = @midddleware.send(:js_files, {:css_id => 'css_id', :token => 'token', :auto_complete => true})
    actual_result.should == expected
  end

  it "should return default" do
    expected = <<-EOF
<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1');
  google.setOnLoadCallback(function() {
    var customSearchControl = new google.search.CustomSearchControl('token');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    var options = new google.search.DrawOptions();
    
    customSearchControl.draw('css_id', options);
  }, true);
</script>
EOF
    
    actual_result = @midddleware.send(:js_files, {:css_id => 'css_id', :token => 'token', :auto_complete => false})
    actual_result.should == expected
  end
end
