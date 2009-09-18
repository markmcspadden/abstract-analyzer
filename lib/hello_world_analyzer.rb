class HelloWorld
  # Our middleware gets called and a Rack environment
  # is being passed.
  def call(env)
    # Here we do our things and return a Rack response.
    # A Rack response is just an array with the response status code
    # headers and body
    [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
  end
end