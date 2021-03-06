# Change these
server "146.59.250.90", port: 22, roles: [:web, :app, :db], primary: true

set :repo_url, "git@gitlab.com:thomaschauffour/e-artsup-gestioncommerciale.git"
set :application, "EARTSUPGestionCommerciale"
set :user, "thomas"
set :puma_threads, [12, 32]
set :puma_workers, 0

# Don't change these unless you know what you're doing
set :pty, false
set :use_sudo, false
set :stage, :production
set :deploy_via, :remote_cache
set :rvm_ruby_version, "2.6.6"
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :linked_files, %w{config/credentials/production.key}

append :linked_dirs, "storage"

# set :sidekiq_roles, :app
# set :sidekiq_default_hooks, true
# set :sidekiq_pid, File.join(shared_path, "tmp", "pids", "sidekiq.pid") # ensure this path exists in production before deploying.
# set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
# set :sidekiq_log, File.join(shared_path, "log", "sidekiq.log")

# set :sidekiq_service_unit_name, "sidekiq"
# set :sidekiq_service_unit_user, :user # set :system
# set :sidekiq_enable_lingering, true
# set :sidekiq_lingering_user, nil

set :sidekiq_service_unit_name, "sidekiq"
set :sidekiq_service_unit_user, :system # set :system
# set :sidekiq_enable_lingering => true
# set :sidekiq_lingering_user => nil
set :sidekiq_user, "thomas"
# set :sidekiq_user => nil
## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc "Create Directories for Puma Pids and Socket"
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc "Initial Deploy"
  task :initial do
    on roles(:app) do
      before "deploy:restart", "puma:start"
      invoke "deploy"
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:stop"
      invoke "puma:start"
    end
  end

  before :starting, :check_revision
  after :finishing, :compile_assets
  after :finishing, :cleanup
  after :finishing, :restart
end
