require "../../../requires"

require "./job"

jobs = {} of String => Command::Fuzzer::Job

job1 = Command::Fuzzer::Job.new
job1.name = "Default"
job1.target = "192.168.1.10"
job1.port = 34567
job1.username = "admin"
job1.password = ""
job1.commands = (0x03e0_u16..0x08FF_u16)
job1.template = Command::Blank.new


jobs[job1.uuid.to_s] = job1

reports_folder = "./reports/"

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
  get "/job/:uuid/save" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    if job = jobs[uuid]?
      job.save
    end

    env.redirect env.request.headers["Referer"]
  end

  get "/job/:uuid/start" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    if job = jobs[uuid]?
      job.start
    end

    env.redirect env.request.headers["Referer"]
  end

  get "/job/:uuid/stop" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    if job = jobs[uuid]?
      job.stop
    end
    env.redirect env.request.headers["Referer"]
  end

  get "/job/:uuid/info" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    job = jobs[uuid]?
    if job
      # sort job results to unique messages
      unique_results = {} of UInt64 => Array(Command::Fuzzer::Result)

      bad_results  = job.bad_fuzzer.results.select(&.bad?)
      results  = job.fuzzer.results.reject(&.bad?) + job.bad_fuzzer.results.reject(&.bad?)

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

  get "/job/:uuid/results" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    job = jobs[uuid]?
    if job

      bad_results  = job.bad_fuzzer.results.select(&.bad?)
      good_results  = job.fuzzer.results.reject(&.bad?) + job.bad_fuzzer.results.reject(&.bad?)
      all_results = bad_results + good_results

      render "src/fuzzer/command/web/views/job_results_all.ecr", "src/fuzzer/command/web/views/layout.ecr" 
    else
      halt env, status_code: 404, response: "What u doing boss?"    
    end
  end

  get "/job/:uuid/result/:result" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
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

  get "/job/:uuid/delete" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    jobs[uuid].stop
    jobs.delete(uuid)
    env.redirect env.request.headers["Referer"]
  end

  get "/reports" do
    # Display all reporting
    # MAKE SO LIVE JOBS ARE DISPLAYED AND SAVED WHEN REQUESTED
    live_reports = jobs.values.map do |job| 
      report = Command::Fuzzer::Report.new
      report.name = job.name
      report.uuid = job.uuid.to_s
      report.results = job.get_all_results
      report
    end

    report_files = Dir.entries(reports_folder).reject {|x| x[0] == '.'}

    reports = report_files.map do |file|
      Command::Fuzzer::Report.from_json(File.read(reports_folder + file))
    end

    render "src/fuzzer/command/web/views/reports.ecr", "src/fuzzer/command/web/views/layout.ecr"
  end

  get "/reports/:uuid" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    report = Command::Fuzzer::Report.from_json(File.read(reports_folder + uuid))
    if report
      # sort job results to unique messages
      unique_results = {} of UInt64 => Array(Command::Fuzzer::Result)

      bad_results = report.results.select(&.bad?)
      results = report.results.select(&.good?)

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
      render "src/fuzzer/command/web/views/report_info.ecr", "src/fuzzer/command/web/views/layout.ecr" 
    else
      halt env, status_code: 404, response: "What u doing boss?"    
    end
  end

  get "/reports/:uuid/delete" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
    begin
      File.delete(reports_folder + uuid)
    rescue
      halt env, status_code: 404, response: "What u doing boss?"    
    end
    env.redirect env.request.headers["Referer"]
  end

  get "/reports/:uuid/result/:result" do |env|
    uuid = env.params.url["uuid"]
    halt env, status_code: 404, response: "What u doing boss?" unless uuid =~ /[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}/
    report = Command::Fuzzer::Report.from_json(File.read(reports_folder + uuid))

    if report
      result = report.results.find {|result| result.message.command.to_s == env.params.url["result"]}
      if result
        render "src/fuzzer/command/web/views/result.ecr", "src/fuzzer/command/web/views/layout.ecr" 
      else 
        halt env, status_code: 404, response: "What u doing boss?"  
      end
    else
      halt env, status_code: 404, response: "What u doing boss?"  
    end
  end

  Kemal.run
end

sleep
