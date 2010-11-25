# -*- coding: utf-8 -*-
module Rack #:nodoc:
  class GoogleCustomSearch < Struct.new :app, :options
    DEFAULTS_OPTIONS = {:css_id => 'cse', :auto_complete => false}
    def call(env)
      status, headers, response = app.call(env)
      
      if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
        body = ""
        response.each { |part| body << part }
        index = body.rindex("</body>")
        if index
          body.insert(index, js_files(DEFAULTS_OPTIONS.merge(options)))
          headers["Content-Length"] = body.length.to_s
          response = [body]
        end
      end

      [status, headers, response]
    end

    protected

    # Returns JS to be embeded. 
    def js_files(options={})
      returning_value = <<-EOF
<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1');
  google.setOnLoadCallback(function() {
    var customSearchControl = new google.search.CustomSearchControl('#{options[:token]}');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    var options = new google.search.DrawOptions();
    #{auto_complete(options[:auto_complete])}
    customSearchControl.draw('#{options[:css_id]}', options);
  }, true);
</script>
EOF
      returning_value
    end
    
    def auto_complete(cond)
      'options.setAutoComplete(true);' if cond
    end
  end
end
