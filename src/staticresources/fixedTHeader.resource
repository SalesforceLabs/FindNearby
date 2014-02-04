(function($)
{
    $.fn.freezeHeaders = function(options) {    	    	
    	var index = 0;    	    	
    	
    	var defaults = {
          	headerId : "header",
           	contentId : "content"           	
        };
            	
        var options = $.extend(defaults, options);
    	
        return this.each(function() {
            var obj = $(this);                       
            
            var hasThead = obj.find("thead").size() > 0;
            var hasTbody = obj.find("thead").size() > 0;
            
            if(obj.is("table") && hasThead && hasTbody) {
            	var widths = [];

    			// capture widths before rearranging
    			obj.find("thead td").each(function(i) {
    				widths.push($(this).width());
    			});
    			
    			var id1 = false, id2 = false;
    			var attrId = obj.attr("id");
    			
    			if(attrId) {
    				id1 = attrId + "_header";
    				id2 = attrId + "_content";
    			}
    			
    			var headerId = (id1 || options.headerId) + index;
    			var contentId = (id2 || options.contentId) + index++;
    			
    			// insert header after the current table
                var header = $("<div><table></table></div>").attr("id",headerId).css("display","none").css("overflow","hidden").insertAfter(obj);
                // insert content after the header
                var content = $("<div><table></table></div>").attr("id",contentId).css("display","none").css("overflow-y","auto").insertAfter(header);
                
                // set the options
                content.height(options.height);                
                content.width(options.width);                
                
                var headerTable = header.find("table");
                var contentTable = content.find("table");
                
    			obj.find("thead").appendTo(headerTable);
    			obj.find("tbody").appendTo(contentTable);
    			header.css("display", "block");
    			content.css("display", "block");

    			headerTable.width(contentTable.width());
    			
    			copyAttributes(obj.get(0), headerTable, contentTable);

    			var rowId = 0;
    			// find the first possible row, which has the same number
    			// of columns as the header. This step is to avoid rows containing
    			// columns that span across multiple columns.
    			contentTable.find("tr").each(function(i) {
    				if($(this).children().size() == widths.length) {
    					rowId = i;
    					return false;
    				}
    			});

    			headerTable.find("td").each(function(i) {
    				var selector = "#" + contentId + " tr:eq(" + rowId + ") td:eq("+ i +")";
    				$(selector).wrapInner("<div></div>");
    				$(selector + " div").width(widths[i]);
    				$(this).wrapInner('<div style="width:' + widths[i] + ';"></div>');
    			});
            }
        });
        
        function copyAttributes(elem, headerTable, contentTable) {
	    	for (var i = 0; i < elem.attributes.length; i++) {
    		  var attrib = elem.attributes[i];
    		  if (attrib.specified && attrib.name != "id") {    		    
    		    headerTable.attr(attrib.name,attrib.value);
    		    contentTable.attr(attrib.name,attrib.value);
    		  }
    		}
        }
    }

})(jQuery);