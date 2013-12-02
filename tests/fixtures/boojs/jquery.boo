import Apis(jQuery)

# Static method
assert true == jQuery.isArray([1,2,3])

# Factory plus chained call
jQuery('.foo').each({itm| print itm})

# Saved factory, plus callable and chained call
jq = jQuery()
jq('.foo').each({itm| print itm })
