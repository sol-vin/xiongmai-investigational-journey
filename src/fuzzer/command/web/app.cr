require "../../../requires"

require "./job"

jobs = {} of String => Command::Fuzzer::Job

job1 = Command::Fuzzer::Job.new
job1.name = "Default"
job1.target = "192.168.1.10"
job1.port = 34567
job1.username = "admin"
job1.password = ""
job1.commands = (0x_u16..0x1000_u16)

jobs[job1.uuid.to_s] = job1

spawn do
  get "/" do |env|

    # Displays an alert if certain events happen
    display_alert = false
    alert_type = "dark"
    alert_message = "Nothing to report!"

    if env.params.query["success"]? == "true" && env.params.query["event"]? == "job_created"
      display_alert = true
      alert_type = "success"
      alert_message = "Job successfully created! <i class=\"fas fa-thumbs-up\"></i>"
    elsif env.params.query["success"]? == "false" && env.params.query["event"]? == "job_created"
      display_alert = true
      alert_type = "danger"
      alert_message = "Job successfully failed! <i class=\"fas fa-sad-cry\"></i>"
    end

    render "src/fuzzer/command/web/views/home.ecr", "src/fuzzer/command/web/views/layout.ecr"
  end

  # Make a new job
  post "/job/new" do |env|
    success = true
    begin 
      raise "Bad Ip Address" unless env.params.body["target"] =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
      # to_i raises an error as well as raise an error if zero.
      raise "Bad port" if env.params.body["port"].to_u16.zero?

      raise "Bad range" unless (env.params.body["range_start"].to_u16...env.params.body["range_end"].to_u16)


      job = Command::Fuzzer::Job.new
      job.name = env.params.body["name"]
      job.target = env.params.body["target"]
      job.port = env.params.body["port"].to_u16
      job.username = env.params.body["username"]
      job.password = env.params.body["password"]
      job.commands = (env.params.body["range_start"].to_u16...env.params.body["range_end"].to_u16)
      jobs[job.uuid.to_s] = job
      # TODO: Make a list of templates, reference templates here
    rescue e
      puts "ERROR: #{e.inspect}"
      success = false
    end
    env.redirect "/?success=#{success}&event=job_created"
  end

  # Display a specific job id
  get "/job/:uuid" do
  end

  get "/job/:uuid/start" do |env|
    uuid = env.params.url["uuid"]
    if job = jobs[uuid]?
      job.start
    end

    env.redirect env.request.headers["Referer"]
  end

  get "/job/:uuid/stop" do |env|
    uuid = env.params.url["uuid"]
    if job = jobs[uuid]?
      job.stop
    end
    env.redirect env.request.headers["Referer"]
  end

  get "/job/:uuid/info" do |env|
    uuid = env.params.url["uuid"]
    job = jobs[uuid]?
    if job
      # sort job results to unique messages
      unique_results = {} of UInt64 => Array(Command::Fuzzer::Result)

      bad_results  = job.fuzzer.results.select(&.bad?)
      results  = job.fuzzer.results.reject(&.bad?)

      results.each do |result|
        message = result.message.message
        reply = nil
        if result.good?
          reply = result.reply.as(XMMessage).message
        end
        unless unique_results[reply.hash]?
          unique_results[reply.hash] = [] of Command::Fuzzer::Result
        end
        unique_results[reply.hash] << result
      end
      render "src/fuzzer/command/web/views/job_info.ecr", "src/fuzzer/command/web/views/layout.ecr" 
    else
      halt env, status_code: 404, response: "What u doing boss?"    
    end
  end

  get "/job/:uuid/result/:result" do |env|
    uuid = env.params.url["uuid"]
    job = jobs[uuid]?
    if job
      result = job.fuzzer.results.find {|result| result.message.command.to_s == env.params.url["result"]}
      if result
        render "src/fuzzer/command/web/views/result.ecr", "src/fuzzer/command/web/views/layout.ecr" 
      else 
        halt env, status_code: 404, response: "What u doing boss?"  
      end
    else
      halt env, status_code: 404, response: "What u doing boss?"  
    end
  end

  get "/job/:uuid/settings" do
    # TODO: Ensure settings cannot be changed while fuzzer is running
  end

  get "/job/:uuid/delete" do
    # delete a job
  end

  get "/job/:uuid/results" do
    # Current lisrt of results
  end

  get "/job/:uuid/s/:sock_uuid" do
    # Display statistics for a jobs socket
  end

  Kemal.run
end

sleep
