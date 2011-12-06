#!/usr/bin/env ruby
USERNAME = 'hogehoge'
PASSWORD = 'foobar'
# ----------- ----------- ----------- ----------- ----------- -----------
require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rexml/document'
require 'pp'
require 'optparse'

XMLFILE  = './tc.xml'

MAINBODY=<<'EOS'
eq($NUMBER$, (new $CLASSNAME$()).$METHODNAME$($PARAMETER$), $ANSWER$);
EOS

TESTCODE=open("./template/TestTemplate.java",'r').read
YOURCODE=open("./template/CodeTemplate.java",'r').read



class AirSRM

  def initialize options
    @overwrite = options[:force]
    @srm = options[:srm].to_i
    @div = options[:div].to_i
    @level = options[:level].to_i
    @agent = Mechanize.new do |a|
      a.user_agent_alias = 'Mechanize'
    end


    @rd = getRoundId()
    @problem = getProblem()
    @pm = @problem[:id]
    @fnStatement = "#{@problem[:name]}.html"
    @fnParameter = "#{@problem[:name]}.systemtest.html"
    @fnTestCode = "Test#{@problem[:name]}.java"
    @fnYourCode = "#{@problem[:name]}.java"
  end

  def login
    return if @agent.cookie_jar.jar[".topcoder.com"]
    print "Login to TopCoder.com ... "
    page = @agent.get('https://community.topcoder.com/tc?&module=Login')

    sys_form = page.form("frmLogin")
    sys_form.field_with(:name => 'username').value = USERNAME
    sys_form.field_with(:name => 'password').value = PASSWORD

    page = @agent.submit(sys_form)

    unless page.body.index("Forgot") == nil
      puts "Login error"
      exit
    end
    puts "Done."
  end

  def getRoundId
    if (not File.exist?(XMLFILE)) or (@overwrite)
      print "Saving a round list ... "
      open(XMLFILE,'w') do |file|
        file.write(@agent.get("http://www.topcoder.com/tc?module=BasicData&c=dd_round_list").body)
      end
      puts "Done."
    end
    roundList = REXML::Document.new(File.open(XMLFILE,'r').read)

    roundList.elements.each("dd_round_list/row") do |i|
      if i.elements["short_name"].text =~ /#{@srm}/
        return i.elements["round_id"].text
      end
    end

    puts "SRM not found."
    exit
  end

  def getProblem
    # https://community.topcoder.com/stat?c=round_overview&er=0&rd=14550
    page = @agent.get("https://community.topcoder.com/stat?c=round_overview&er=0&rd=#{@rd}")
    problemList = page.links.map do |i|
      {:url=>i.uri.to_s,:name=>i.text}
    end.delete_if do |i|
      not (i[:url] =~ /problem_statement/)
    end
    
    ret = problemList[3*(@div-1)+@level-1]
    ret[:id] = ret[:url].sub(/.*pm=/,'').sub(/&rd.*/,'')
    ret
  end

  def saveStatement

    if File.exist?(@fnStatement) and (not @overwrite)
      puts "The problem statement, #{@fnStatement}, exists."
      return
    end
      
    login()
    origin = "http://community.topcoder.com/stat?c=problem_statement&pm=#{@pm}&rd=#{@rd}"
    page = @agent.get(origin)
    flag = false
    cnt = ["<html><body>",
           "<p><a href=\"#{origin}\">#{page.body.scan(/<a .*?ProblemDetail.*?>(.*?)<\/a>/).flatten.first}</a> on community.topcoder.com</p>"
    ]
    page.body.split("\n").each do |i|
      if i =~ /BEGIN BODY/
        flag = true
      elsif i =~ /END BODY/
        break
      end
      cnt << i.gsub(/BGCOLOR=".*?"/,'') if flag
    end
    cnt << "</body></html>"

    cnt = cnt.join("\n")
    cnt.gsub!(/<IMG.*?>/,'')
    cnt.gsub!(/BACKGROUND=".*?"/,'')
    cnt.gsub!(/<TD.*?>\s*?<\/TD>/,'')
    cnt.gsub!(/<TD.*?bodyTextBold.*?>.*?<\/TD>/m,'')
    cnt.gsub!(/<TR.*?>\s*?<\/TR>/,'')
    cnt.gsub!(/<TABLE.*?>\s*?<\/TABLE>/,'')
    cnt.gsub!(/^\s*$/,'')
    cnt.gsub!(/\n+/,"\n")


    print "Saving the statement, #{@fnStatement} ... "
    open(@fnStatement,"w") do |file|
      file.write(cnt)
    end
    puts "Done."
  end

  def saveSystemTestParam
    if File.exist?(@fnParameter) and (not @overwrite)
      puts "The test cases, #{@fnParameter}, exist."
      return
    end

    login()
    # http://community.topcoder.com/tc?module=ProblemDetail&rd=14550&pm=11665
    page = @agent.get("http://community.topcoder.com/tc?module=ProblemDetail&rd=#{@rd}&pm=#{@pm}")

    solutions = page.links.map {|i| i.uri.to_s}.delete_if {|i| not (i =~ /solution&cr=\d/)}
    if solutions.length == 0
      puts "Fatal Error (no solution)"
      exit
    end
    page = @agent.get(solutions.first)

    flag = false
    cnt = ["<html><body>",
           "<p><a href=\"http://community.topcoder.com/stat?c=round_stats_sorted&rd=#{@rd}&dn=#{@div}&sq=Round_Statistics_Data&sc=10&sd=desc\">Match Result</a> on community.topcoder.com</p>",
    "<p>Parameters and expected results</p>"]
    page.body.split("\n").each do |i|
      if i =~ /- System/
        flag = true
      elsif i =~ /End System/
        break
      end
      cnt << i if flag
    end
    cnt << "</body></html>"


    cnt = cnt.join("\n")
    cnt.gsub!(/BGCOLOR=".*?"/,'')
    cnt.gsub!(/BACKGROUND=".*?"/,'')
    cnt.gsub!(/<IMG.*?>/,'')
    cnt.gsub!(/<TD.*?>\s*?<\/TD>/,'')
    cnt.gsub!(/<TD.*?>Passed<\/TD>/,'')
    cnt.gsub!(/<TD.*?middle.*?>.*?<\/TD>/m,'')
    cnt.gsub!(/<TD.*?statTextBig.*?>.*?<\/TD>/m,'')
    cnt.gsub!(/<TR.*?>\s*?<\/TR>/,'')
    cnt.gsub!(/^\s*$/,'')
    cnt.gsub!(/\n+/,"\n")
    cnt.sub!(/BORDER="0"/,'BORDER="1"')


    print "Saving test cases, #{@fnParameter} ... "
    open(@fnParameter,"w") do |file|
      file.write(cnt)
    end
    puts "Done."
  end

  def getDefinition fn
    cnt = Hpricot(open(fn,"r").read)
    arr = (cnt/:tr).map {|i| (i/:td).map {|j| j.inner_html}}.delete_if {|i|
      %W[Returns Parameters Method Class].inject(true) {|s,j| s = s and (i[0] != (j+":"))}
    }
    ret = {}
    arr.each do |i|
      ret[:"#{i[0].sub(/:/,'').downcase}"] = i[1].gsub(/\s+/,'')
    end
    ret
  end


  def genMainCode n,definition, parameter
    parText = definition[:parameters].split(",").zip(parameter[0].split("\n")).map do |i,j|
      i =~ /\[\]/ ? "new #{i}#{j}" : j
    end.join

    ret = String.new(MAINBODY)
    ret.sub!(/\$NUMBER\$/,n.to_s)
    ret.sub!(/\$CLASSNAME\$/,definition[:class])
    ret.sub!(/\$METHODNAME\$/,definition[:method])
    ret.sub!(/\$PARAMETER\$/,parText)
    ret.sub!(/\$ANSWER\$/,parameter[1])
    ret.gsub!(/",/,"\",\n")
    ret
  end

  def genYourCode definition
    cnt = open(@fnStatement,"r").read.gsub(/<pre>/,'').gsub(/<\/pre>/,'').gsub(/&quot;/,"\"")
    cnt = Hpricot(cnt)/:table/:tr/:td/:table/:tr/:td/:table/:tr/:td/:table/:tr/:td
    
    arr = (cnt/:table/:tr/:td).map {|i| i.inner_html}
    params = arr.delete_if {|i| i=~/\.$/}
   
    arr = cnt.map {|i| i.inner_html}
    returns = arr.delete_if {|i| not i=~/Returns: /}.map{|i| i.sub(/Returns: /,'')}

    arr = cnt.map {|i| i.inner_html}
    methodparms = arr[arr.index("Method signature:")+1].scan(/\((.*?)\)/).flatten.first

    np = params.length / returns.length
    main = ''
    returns.length.times do |i|
      main += genMainCode(i,definition,[params[np*i..np*i+np-1].join(",\n"),returns[i]])
    end

    ret = String.new(YOURCODE)
    ret.sub!(/\$MAINBODY\$/,main)
    ret.gsub!(/\$CLASSNAME\$/,definition[:class])
    ret.gsub!(/\$RC\$/,definition[:returns])
    ret.gsub!(/\$METHODNAME\$/,definition[:method])
    ret.gsub!(/\$METHODPARMS\$/,methodparms)
    ret.gsub!(/\$BEGINCUT\$/,'// BEGIN CUT HERE')
    ret.gsub!(/\$ENDCUT\$/,'// END CUT HERE')
    ret.gsub!(/\$PROBLEMDESC\$/,'')
    ret.gsub!(/\$WRITERCODE\$/,'')
    ret
  end

  def saveYourCode
    if File.exist?(@fnYourCode) # not depend on "force" option.
      puts "#{@fnYourCode} exists."
      return
    end

    df = getDefinition(@fnStatement)
    print "Saving #{@fnYourCode} ... "
    open(@fnYourCode,"w") do |file|
      file.write(genYourCode(df))
    end
    puts "Done."
  end

  def genTestCode definition,parameters
    main = ''
    parameters.length.times do |i|
      main += genMainCode(i,definition,parameters[i])
    end
   
    ret = String.new(TESTCODE)
    ret.sub!(/\$CLASSNAME\$/,@problem[:name])
    ret.sub!(/\$MAINBODY\$/,main)
    ret
  end


  def saveSystemTest
    def getParameters fn
      (Hpricot(open(fn,'r').read)/:tr).map {|i| (i/:td).map {|i| i.inner_html}}
    end
    if File.exist?(@fnTestCode) and (not @overwrite)
      puts "Test code, #{@fnTestCode}, exists."
      return
    end

    saveStatement
    df = getDefinition(@fnStatement)

    saveSystemTestParam
    pa = getParameters(@fnParameter)

    print "Saving #{@fnTestCode} ... "
    open(@fnTestCode,"w") do |file|
      file.write(genTestCode(df,pa))
    end
    puts "Done."
  end


end


options = {}
options[:systemtest] = false
options[:force] = false
optparse = OptionParser.new do |opts|
  opts.on('--systemtest') do
    options[:systemtest] = true
  end
  opts.on('-f','--force') do
    options[:force] = true
  end
  opts.on('--srm=VAL') do |v|
    options[:srm] = v
  end
  opts.on('--div=VAL','--division=VAL') do |v|
    if v == "1" or v == "2"
      options[:div] = v
    else
      puts "--division=[1-2]"
      exit
    end
  end

  opts.on('--lv=VAL','--level=VAL') do |v|
    if 1 <= v.to_i and v.to_i <= 3
      options[:level] = v
    else
      puts "--level=[1-3]"
      exit
    end
  end

end
optparse.parse!

if (options[:systemtest])
  AirSRM.new(options).saveSystemTest
else
  tmp = AirSRM.new(options)
  tmp.saveStatement
  tmp.saveYourCode
end

