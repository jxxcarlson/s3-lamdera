# Experimental S3 uploader for Lamdera

- Current status: one can select a file (.png or .jpg).  It will be uploaded
to the app, some metadata,e.g., mime type will be stored and displayed, and
the file contents will be converted to a Base64-encoded string which is then
stored in the model.

- To do next:  Figure out how to create a presigned url.  This requires
construct a somewhat tricky request to Amazon S3.

- And then: do the actual upload to S3. This should be relatively easy. 
