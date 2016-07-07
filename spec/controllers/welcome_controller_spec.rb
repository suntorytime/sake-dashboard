require 'spec_helper'
require 'rails_helper'

def fetch_twitter
  consumer_key = OAuth::Consumer.new(
      ENV["CONSUMER_KEY"],
      ENV["CONSUMER_SECRET"])
  access_token = OAuth::Token.new(
      ENV["ACCESS_TOKEN"],
      ENV["ACCESS_TOKEN_SECRET"])

  # All requests will be sent to this server.
  baseurl = "https://api.twitter.com"

  # The verify credentials endpoint returns a 200 status if
  # the request is signed correctly.
  address = URI("#{baseurl}/#{ENV["SAKE_URL"]}")

  # Set up Net::HTTP to use SSL, which is required by Twitter.
  http = Net::HTTP.new address.host, address.port
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Build the request and authorize it with OAuth.
  request = Net::HTTP::Get.new address.request_uri
  request.oauth! http, consumer_key, access_token

  # Issue the request and return the response.
  http.start
  @response = http.request request
end

describe WelcomeController do
  describe 'GET #index' do
    it "renders the :index view" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe 'Query Twitter API' do
    it 'returns a 200 response code' do
      fetch_twitter
      expect(@response.code).to eq("200")
    end
    it 'returns an array of Twitter objects' do
      fetch_twitter
      timeline = JSON.parse(@response.body)
      @tweets = timeline["statuses"]
      expect(@tweets).to be_an_instance_of(Array)
    end

  end
end