module Rack #:nodoc:
  class GoogleCustomSearch < Struct.new :app, :options

    def call(env)
      status, headers, response = app.call(env)

      if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
        body = ""
        response.each { |part| body << part }
        index = body.rindex("</body>")
        if index
          body.insert(index, js_files(options[:token]))
          headers["Content-Length"] = body.length.to_s
          response = [body]
        end
      end

      [status, headers, response]
    end

    protected

      # Returns JS to be embeded. 
      def js_files(token)
        returning_value = <<-EOF
<script src="http://www.google.com/jsapi" type="text/javascript"></script>
<script type="text/javascript">
  google.load('search', '1');
  google.setOnLoadCallback(function() {
    var customSearchControl = new google.search.CustomSearchControl('#{token}');
    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
    customSearchControl.draw('cse');
  }, true);
</script>
EOF
      returning_value
      end
  end
end
