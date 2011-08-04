echo '{"method":"ADD", "content":{"type":"RESTful", "name":"echo", "spec_uri":"http://localhost:4567/process.json"}}' | nc localhost 3141
echo '{"method":"SEND", "content":{"process":"echo", "channel":"say", "content":"hola"}}' | nc localhost 3141
echo '{"method":"LIST"}' | nc localhost 3141
