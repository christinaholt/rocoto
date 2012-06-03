##########################################
#
# Module WorkflowMgr
#
##########################################
module WorkflowMgr

  ##########################################  
  #
  # Class WorkflowStatusOpt
  #
  ##########################################
  ### to call:  ./workflowstatusopt.rb -x junk -c "c1, c2, c3" -d dbfile -t "tk1, tk2, tk3"
  ###

  class WorkflowStatusOpt

    require 'optparse'
    require 'pp'                      
    require 'parsedate'
    
    attr_reader :database, :workflowdoc, :cycles, :tasks

    ##########################################  
    #
    # Initialize
    #
    ##########################################
    def initialize(args)

      @database=nil
      @workflowdoc=nil
      @cycles=[]
      @tasks=[]
      parse(args)

    end  # initialize

  private

    ##########################################  
    #
    # parse
    #
    ##########################################
    def parse(args)

      OptionParser.new do |opts|

        # Command usage text
        opts.banner = "Usage:  workflowstatus -d database_file -w workflow_document [-c cycle_list] [-t task_list]"

        # Specify the database file
        opts.on("-d","--database file",String,"Path to database store file") do |db|
          @database=db
        end
     
        # Specify the XML file
        opts.on("-w","--workflow PATH",String,"Path to workflow definition file") do |workflowdoc|
          @workflowdoc=workflowdoc
        end

        # Cycles of interest
        #      C   C,C,C  C:C  :C   C:
        #        where C='YYYYMMDDHHMM', C:  >= C, :C  <= C

        cyclelist = []
        opts.on("-c","--cycles '1,2,3'",Array,"List of cycles") do |clist|
          @cycles=cyclelist
          clist.each do |c|
            parsed_date = ParseDate.parsedate(c)
            tm = Time.utc(parsed_date[0], parsed_date[1], parsed_date[2], parsed_date[3], 
#                          parsed_date[4]).strftime("%a %b %d %H:%M:%S %z %Y")
                          parsed_date[4])
            cyclelist << tm
          end
          @cycles=cyclelist
        end
     
        # Tasks of interest
        opts.on("-t","--tasks 'a,b,c'",Array,"List of tasks") do |tasklist|
          @tasks=tasklist
        end
     
        # Help
        opts.on("-h","--help","Show this message") do
          puts opts
          exit
        end

        begin

          # If no options are specified, turn on the help flag
          args=["-h"] if args.empty?

          # Parse the options
          opts.parse!(args)

          # The -d and -w options are mandatory
          raise OptionParser::ParseError,"A database file must be specified" if @database.nil?
          raise OptionParser::ParseError,"A workflow definition file must be specified" if @workflowdoc.nil?
  
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n",opts
          exit(-1)
        end
        
      end

      ###  
     
    end  # parse

  end  # Class WorkflowStatusOpt

end  # Module WorkflowMgr
