# Load DSL and Setup Up Stages
require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/rails"
require "capistrano/bundler"
require "capistrano/rvm"
require "capistrano/puma"
require "capistrano/rails/db"
require "capistrano/scm/git"
require "capistrano/bundler"
require "capistrano/ssh_doctor"
require "capistrano/faster_assets"
require "capistrano/sidekiq"

install_plugin Capistrano::Sidekiq
install_plugin Capistrano::Sidekiq::Systemd

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Daemon
# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

require 'appsignal/capistrano'
