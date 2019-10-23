require "../../../requires"

def make_new_job(job_name : String,
                 commands : Enumerable = (0x03e0..0x08FF),
                 username = "admin",
                 password = "",
                 hash_password = true,
                 login = true,
                 target_ip = "192.168.1.10",
                 template = XMMessage.new)
  spawn do
    fuzzer = Commad::Fuzzer.new(commands, username, password, hash_passwordm login, target_ip, template)
  end
end

spawn do
  get "/" do
    # Display basic menu/jobs running
    render "src/fuzzer/command/web/views/home.ecr", "src/fuzzer/command/web/views/layout.ecr"
  end

  get "/jobs/running" do
    # Display the running jobs
  end

  get "/jobs/paused" do
    # Display paused jobs
  end

  get "/jobs/finished" do
    # Display finished jobs
  end

  get "/job/new" do
    # make a new job
  end

  post "/job/new" do
    # Post with job details
  end

  get "/job/:id" do
    # Display a specific job id
  end

  get "/job/:id/pause" do
    # Pause a job
  end

  get "/job/:id/start" do
    # Start a job
  end

  get "/job/:id/delete" do
    # delete a job
  end

  get "/job/:id/results" do
    # Current lisrt of results
  end

  get "/job/:id/socket/:sock_id/stats" do
    # Display statistics for a jobs socket
  end

  Kemal.run
end

sleep