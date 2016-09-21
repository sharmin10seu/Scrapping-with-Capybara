require 'capybara'
require 'capybara/dsl'
require 'csv'
require 'headless'
require 'capybara-webkit'

Capybara.run_server = false
Capybara.default_driver = :webkit
#Capybara.javascript_driver = :webkit
Capybara.app_host = 'https://github.com/kubernetes/kubernetes/stargazers'

Capybara::Webkit.configure do |config|
  #config.block_unknown_urls
  config.skip_image_loading
  config.allow_url("github.com")
  config.block_url "*.js*"
  config.block_url "*.css*"
end

class Github
  include Capybara::DSL
  attr_accessor :user, :csv, :headless

  def initialize
    @users = []
    @csv = CSV.open("data.csv", "w", {:headers => ["URL","Email"]})
    @headless ||= Headless.new
    @headless.start
  end

  def parse_github_users
    visit('/')
    page_number = 1

    while(next_link=(page.find(".pagination a", :text => 'Next') rescue nil))
      page.all(:css, 'h3.follow-list-name span.css-truncate a').each do |user|
        @users << {:text => user.text, :url => 'https://github.com' + user[:href]}
      end
      puts "Page Number #{page_number}"
      if page_number % 41
        puts "waiting extra 90 seconds.."
        sleep 90
      end

      page_number += 1
      next_link.click if next_link
    end
  end

  def save_to_csv
    @users.each do |user|
      visit user[:url]
      email = page.find('ul.vcard-details li[aria-label="Email"] a').text rescue ""
      puts "Saving data for #{user[:url]} with email: #{email}"
      @csv << [user[:url],email]
    end
    @csv.close
    @headless.destroy if @headless
  end
end

begin
  github = Github.new
  puts "Parsing started..."
  github.parse_github_users
  puts "Saving data into CSV file..."
  github.save_to_csv
rescue Exception => e
  puts e.message
end