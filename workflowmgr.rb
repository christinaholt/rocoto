#!/usr/bin/ruby

if File.symlink?(__FILE__)
  $:.unshift(File.dirname(File.readlink(__FILE__))) unless $:.include?(File.dirname(File.readlink(__FILE__))) 
else
  $:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) 
end
$:.unshift("#{File.dirname(__FILE__)}/libxml-ruby-0.8.3/ext/libxml")

require 'optparse'
require 'workflow.rb'
require 'lockfile/lib/lockfile.rb'

UPDATE_INTERVAL=60

xmlfile=nil
storefile=nil
haltfile=nil
shutdown=false
shutdowncycles=nil
doloop=false

lock_opts={
        :retries => 1,
        :max_age => 900,
        :refresh => 60,
        :timeout => 10,
        :poll_retries => 16,
        :poll_max_sleep => 0.08,
        :debug => false
}


# Define the valid options
opts=OptionParser.new
opts.on("-x","--xml","=XML_FILE",
        "The full path of the XML workflow description file.\n",
        String) { |val| xmlfile=val }
opts.on("-s","--store","=STORE_FILE", 
        "The path of the file used to store the workflow's state.\n",
        String) { |val| storefile=val }
opts.on("--halt","=[YYYYMMDDHH,...]",
        /(\d){10}(,\d{10})*/,
        "Halt each cycle in the cycle list.  The cycle list is specified",
        "as a string of comma separated cycles in yyyymmddhh format.",
        "All running jobs for each cycle in the cycle list are killed.",
        "All workflow progress for each cycle in the cycle list is erased.",
        "The cycles can be resumed later from the beginning if desired.",
        "If a cycle list is not specified, all cycles are halted.\n",
        Array) { |cycles|
                 shutdown=true
                 unless cycles.nil? 
                   shutdowncycles=cycles.collect { |cycle| Time.gm(cycle[0..3],cycle[4..5],cycle[6..7],cycle[8..9]) }
                 end
               }
opts.on("--loop",
        "Run the workflowmgr in an infinite loop.") { |val| doloop=true }

# Parse the options and display usage if options are invalid
begin
  opts.parse(*ARGV)
  raise if xmlfile.nil?
  raise if storefile.nil?
rescue
  puts opts.to_s
  exit
end

# Run the workflow
begin
  lockfile="#{storefile}.lock"
  Lockfile.new(lockfile,lock_opts) do

    if shutdown
      workflow=Workflow.new(xmlfile,storefile)
      workflow.halt(shutdowncycles,ctrl_opts)
    else
      loop do
        workflow=Workflow.new(xmlfile,storefile)
        workflow.run
        break unless doloop
        break if workflow.done?
        sleep UPDATE_INTERVAL
      end
    end

#    workflow=Workflow.new(xmlfile,storefile)
#    workflow.run
  end
rescue Lockfile::MaxTriesLockError,Lockfile::TimeoutLockError,Lockfile::StackingLockError
  puts "The workflow is locked."
  puts 
  puts $!
  exit
end