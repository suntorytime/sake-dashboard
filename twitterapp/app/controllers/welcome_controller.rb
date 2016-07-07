require 'oauth'

class WelcomeController < ApplicationController

  def index
    expires_in 2.minute, public: true
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
    response = http.request request

    if response.code == '200' then
      timeline = JSON.parse(response.body)
      @tweets = timeline["statuses"]

      times = []
      labels = []
      counts = []
      @tweets.each do |t|
        times << t["user"]["time_zone"] unless t["user"]["time_zone"] == nil
      end
      labels = times.uniq
      hash_of_time_zones = times.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }

      hash_of_time_zones.each do |key, count|
        counts << count
      end
      @data = {
    labels: labels,
    datasets: [
        {
            data: counts,
            backgroundColor: [
                "#FF6384",
                "#36A2EB",
                "#FFCE56",
                "#FF6384",
                "#36A2EB",
                "#FFCE56",
                "#FF6384",
                "#36A2EB",
                "#FFCE56"
            ],
            hoverBackgroundColor: [
                "#FF6384",
                "#36A2EB",
                "#FFCE56",
                "#FF6384"
            ]
        }]
};
    end
  end
end
