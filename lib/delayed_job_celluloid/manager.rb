require 'celluloid'
require_relative 'worker'

module DelayedJobCelluloid
  class Manager
    include Celluloid
    
    trap_exit :worker_died
    
    def initialize(options={}, worker_count)
      @options = options
      @worker_count = worker_count || 1
      @done_callback = nil

      @done = false
      @busy = []
      @ready = @worker_count.times.map { Worker.new_link(options, current_actor) }
    end
    
    def start
      @ready.each_with_index do |worker, index|
        worker.name = @worker_count == 1 ? "delayed_job" : "delayed_job.#{index}"
        worker.async.start 
      end
    end

    def stop(options={})
      shutdown = options[:shutdown]
      timeout = options[:timeout]
      
      @done = true
      @ready.each do |worker|
        worker.stop
        worker.terminate if worker.alive?
      end
      @ready.clear
      
      return after(0) { signal(:shutdown) } if @busy.empty?
    end
    
    def work(worker)
      @ready.delete(worker)
      @busy << worker
    end
    
    def worker_done(worker)
      @busy.delete(worker)
      if stopped?
        worker.terminate if worker.alive?
        signal(:shutdown) if @busy.empty?
      else
        @ready << worker if worker.alive?
      end
    end
    
    def worker_died(worker, reason)
      @busy.delete(worker)
      
      unless stopped?
        @ready << Worker.new_link(@options, current_actor)
        worker.async.start
      else
        signal(:shutdown) if @busy.empty?
      end
    end

    def stopped?
      @done
    end
    
  end
end
