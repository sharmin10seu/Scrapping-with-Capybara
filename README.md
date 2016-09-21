Parses https://github.com/apache/spark/stargazers using Capybara in headless mode

How to run the script(for this project directory)

sudo apt-get install xvfb
bundle install
ruby main.rb


CSV file will be saved into root directory of this project.


How to install Qt5 on Linux to use webkit driver on headless

sudo apt-get update
sudo apt-get install qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

run xvfb server on a new console
Xvfb :21 -screen 0 1024x768x24 +extension RANDR &