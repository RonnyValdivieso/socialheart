lock '3.4.1'

set :application, 'socialheart'
set :repo_url, 'http://github.com/RonnyValdivieso/socialheart.git'
set :deploy_to, '/opt/www/socialheart'
set :user, 'deploy'
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets}



namespace :deploy do

  %w[start stop restart].each do |command|
  	desc 'Manage Unicorn'
  	task command do
  		on roles(:app), in: :sequence, wait: 1 do
  			execute "/etc/init.d/unicorn_#{fetch(:application)} #{command}"
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