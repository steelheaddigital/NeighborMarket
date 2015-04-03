job_type :foreman, "cd :path && :environment_variable=:environment bundle exec foreman run :task --silent :output"

every :day, at: "5am" do
  foreman "rake sitemap:generate"
end