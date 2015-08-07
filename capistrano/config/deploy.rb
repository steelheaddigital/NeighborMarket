# config valid only for Capistrano 3.4.0
lock '3.4.0'

set :application, 'neighbormarket'
set :repo_url, 'https://github.com/tmooney3979/NeighborMarket.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/neighbormarket'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_type, :system # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.2.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

set :whenever_environment, ->{ fetch(:stage) }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      invoke "foreman:restart"
    end
  end

  task :seed do
    puts "\n=== Seeding Database ===\n"
    on primary :db do
      within current_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:seed'
        end
      end
    end
  end
  
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end


namespace :foreman do

  desc "Creates the .env file if it does not exist"
  task :create_env_file do
    on roles(:app) do
      unless test("[ -f " + shared_path.to_s + "/.env ]")
        puts "\n\n=== Creating .env file! ===\n\n"
        env = <<-EOF
PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RAILS_ENV=production
HOST=#{fetch(:host_name)}
DEFAULT_FROM=''
SMTP_ADDRESS=''
SMTP_DOMAIN=''
SMTP_USERNAME=''
SMTP_PASSWORD=''
SMTP_PORT=25
SMTP_AUTHENTICATION='plain'
SECRET_KEY_BASE=#{SecureRandom.hex(64)}
SECRET_KEY_SALT=#{SecureRandom.hex(64)}
EOF
        location = fetch(:template_dir, "config/deploy") + '/.env'
        File.open(location,'w+') {|f| f.write env }
        upload! "#{location}", "#{shared_path}/.env"
      end
    end
  end
  
  desc 'Export the Procfile to Ubuntu upstart scripts'
  task :export do
    on roles(:app) do |host|
      log_path         = shared_path.join('log')
      environment_path = fetch(:foreman_env)
      within release_path do
        as :root do
          execute :bundle, "exec foreman export upstart /etc/init -a #{fetch(:application)} -u #{host.user} -l #{log_path}"
        end
      end
    end
  end
  
  desc 'Start the application services'
  task :start do
    on roles(:app) do |host|
      as :root do
        execute :start, fetch(:application)
      end
    end
  end
  
  desc 'Stop the application services'
  task :stop do
    on roles(:app) do |host|
      as :root do
        execute :stop, fetch(:application)
      end
    end
  end
  
  desc 'Restart the application services'
  task :restart do
    on roles(:app) do |host|
      as :root do
        execute :service, "#{fetch(:application)} start || service #{fetch(:application)} restart"
      end
    end
  end
  
  before 'deploy', 'foreman:create_env_file'
  before 'deploy:publishing', 'foreman:export'
end

namespace :sitemaps do
  desc 'Generate a new site map'
  task :generate do
    on roles(:app) do |host|
      within release_path do
        execute :bundle, "exec foreman run rake sitemap:generate RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end
  
  after "deploy:publishing", "sitemaps:generate"
end
