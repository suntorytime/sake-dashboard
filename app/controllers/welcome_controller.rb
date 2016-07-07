require 'oauth'

class WelcomeController < ApplicationController

  def index
    expires_in 2.minute, public: true
    request_twitter
    end
  end

  private
  def request_twitter
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
    # Uses environment variable to enter the rest of the address
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

    # Check if response went through OK, then proceed with process
    if response.code == '200' then

      # initialize chart-related arrays for operations
      chart_time_zones = []
      chart_labels = []
      chart_data = []

      timeline = JSON.parse(response.body)
      @tweets = timeline["statuses"]

      # add time zones from tweets to array
      @tweets.each do |t|
        chart_time_zones << t["user"]["time_zone"] unless t["user"]["time_zone"] == nil
      end

      # find the unique instances of tweets' time zones and assign to chart_labels
      chart_labels = chart_time_zones.uniq

      # count up the number of instances of tweets with respect to time zones
      hash_of_time_zones = chart_time_zones.each_with_object(Hash.new(0)) { |word,chart_data| chart_data[word] += 1 }

      # assign counts of each time zone to an array 'chart_data' for chartjs usage
      hash_of_time_zones.each do |key, count|
        chart_data << count
      end

      # Assign chart data and send to instance variable
      @chart_data = {
        labels: chart_labels,
        datasets: [{
            data: chart_data,
            backgroundColor: [
              "#FF6384",
              "#36A2EB",
              "#FFCE56",
              "#FF194A",
              "#00B21D",
              "#00FF2A",
              "#FF9163",
              "#00B299",
              "#DD00FF"
            ],
            hoverBackgroundColor: [
              "#FF6384",
              "#36A2EB",
              "#FFCE56",
              "#DD00FF",
              "#00B299",
              "#FF9163",
              "#FF194A",
              "#00B21D"
            ]
        }]
      };
  end
end
