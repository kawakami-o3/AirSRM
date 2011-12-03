#!/usr/bin/env ruby
USERNAME = 'hogehoge'
PASSWORD = 'foobar'
# ----------- ----------- ----------- ----------- ----------- -----------
require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'open-uri'
require 'rexml/document'
require 'optparse'

XMLFILE  = './tc.xml'

MAINCODE=<<EOS
eq(NUMBER, (new CLASSNAME()).METHODNAME(PARAMETER), ANSWER);
EOS

WHOLECODE=<<'EOS'
import java.util.*;
public class TestCLASSNAME {
  public static void main(String[] args) {
    try {
MAINCODE
    } catch( Exception exx) {
      System.err.println(exx);
      exx.printStackTrace(System.err);
    }
  }
  private static void eq( int n, int a, int b ) {
    if ( a==b )
      System.err.println("Case "+n+" passed.");
    else {
      System.err.println("Case "+n+" failed: expected "+b+", received "+a+".");
      throw (new RuntimeException("Wrong answer"));
    }
  }
  private static void eq( int n, char a, char b ) {
    if ( a==b )
      System.err.println("Case "+n+" passed.");
    else {
      System.err.println("Case "+n+" failed: expected '"+b+"', received '"+a+"'.");
      throw (new RuntimeException("Wrong answer"));
    }
  }
  private static void eq( int n, long a, long b ) {
    if ( a==b )
      System.err.println("Case "+n+" passed.");
    else {
      System.err.println("Case "+n+" failed: expected \""+b+"L, received "+a+"L.");
      throw (new RuntimeException("Wrong answer"));
    }
  }
  private static void eq( int n, boolean a, boolean b ) {
    if ( a==b )
      System.err.println("Case "+n+" passed.");
    else {
      System.err.println("Case "+n+" failed: expected "+b+", received "+a+".");
      throw (new RuntimeException("Wrong answer"));
    }
  }
  private static void eq( int n, String a, String b ) {
    if ( a != null && a.equals(b) )
      System.err.println("Case "+n+" passed.");
    else {
      System.err.println("Case "+n+" failed: expected \""+b+"\", received \""+a+"\".");
      throw (new RuntimeException("Wrong answer"));
    }
  }
  private static void eq( int n, int[] a, int[] b ) {
    if ( a.length != b.length ) {
      System.err.println("Case "+n+" failed: returned "+a.length+" elements; expected "+b.length+" elements.");
      throw (new RuntimeException("Wrong answer"));
    }
    for ( int i= 0; i < a.length; i++)
      if ( a[i] != b[i] ) {
        System.err.println("Case "+n+" failed. Expected and returned array differ in position "+i);
        print( b );
        print( a );
        throw (new RuntimeException("Wrong answer"));
      }
    System.err.println("Case "+n+" passed.");
  }
  private static void eq( int n, long[] a, long[] b ) {
    if ( a.length != b.length ) {
      System.err.println("Case "+n+" failed: returned "+a.length+" elements; expected "+b.length+" elements.");
      throw (new RuntimeException("Wrong answer"));
    }
    for ( int i= 0; i < a.length; i++ )
      if ( a[i] != b[i] ) {
        System.err.println("Case "+n+" failed. Expected and returned array differ in position "+i);
        print( b );
        print( a );
        throw (new RuntimeException("Wrong answer"));
      }
    System.err.println("Case "+n+" passed.");
  }
  private static void eq( int n, String[] a, String[] b ) {
    if ( a.length != b.length) {
      System.err.println("Case "+n+" failed: returned "+a.length+" elements; expected "+b.length+" elements.");
      throw (new RuntimeException("Wrong answer"));
    }
    for ( int i= 0; i < a.length; i++ )
      if( !a[i].equals( b[i])) {
        System.err.println("Case "+n+" failed. Expected and returned array differ in position "+i);
        print( b );
        print( a );
        throw (new RuntimeException("Wrong answer"));
      }
    System.err.println("Case "+n+" passed.");
  }
  private static void print( int a ) {
    System.err.print(a+" ");
  }
  private static void print( long a ) {
    System.err.print(a+"L ");
  }
  private static void print( String s ) {
    System.err.print("\""+s+"\" ");
  }
  private static void print( int[] rs ) {
    if ( rs == null) return;
    System.err.print('{');
    for ( int i= 0; i < rs.length; i++ ) {
      System.err.print(rs[i]);
      if ( i != rs.length-1 )
        System.err.print(", ");
    }
    System.err.println('}');
  }
  private static void print( long[] rs) {
    if ( rs == null ) return;
    System.err.print('{');
    for ( int i= 0; i < rs.length; i++ ) {
      System.err.print(rs[i]);
      if ( i != rs.length-1 )
        System.err.print(", ");
    }
    System.err.println('}');
  }
  private static void print( String[] rs ) {
    if ( rs == null ) return;
    System.err.print('{');
    for ( int i= 0; i < rs.length; i++ ) {
      System.err.print( "\""+rs[i]+"\"" );
      if( i != rs.length-1)
        System.err.print(", ");
    }
    System.err.println('}');
  }
}
EOS



class AirSRM

  def initialize options
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
  end

  def login
    page = @agent.get('https://community.topcoder.com/tc?&module=Login')
    sys_form = page.form("frmLogin")
    sys_form.field_with(:name => 'username').value = USERNAME
    sys_form.field_with(:name => 'password').value = PASSWORD

    page = @agent.submit(sys_form)

    unless page.body.index("Forgot") == nil
      puts "login error"
      exit
    end
  end

  def getRoundId
    unless File.exist?(XMLFILE)
      #puts "saving a round list"
      open(XMLFILE,'w').write(@agent.get("http://www.topcoder.com/tc?module=BasicData&c=dd_round_list").body)
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

    if File.exist?(@fnStatement)
      puts "The problem statement, #{@fnStatement}, exists."
      exit
    end
      
    login()
    page = @agent.get("http://community.topcoder.com/stat?c=problem_statement&pm=#{@pm}&rd=#{@rd}")
    flag = false
    cnt = ["<html><body>"]
    page.body.split("\n").each do |i|
      if i =~ /BEGIN BODY/
        flag = true
      elsif i =~ /END BODY/
        break
      end
      cnt << i.gsub(/BGCOLOR=".*?"/,'') if flag
    end
    cnt << "</body></html>"

    puts "saving the statement, #{@fnStatement} ..."
    open(@fnStatement,"w").write(cnt.join("\n"))
  end

  def saveSystemTestParam
    if File.exist?(@fnParameter)
      puts "The test cases, #{@fnParameter}, exist."
      exit
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
    cnt = ["<html><body>"]
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
    cnt = cnt.gsub(/BGCOLOR=".*?"/,'').gsub(/BACKGROUND=".*?"/,'').
      gsub(/<IMG.*?>/,'').
      gsub(/<TD.*?>\s*?<\/TD>/,'').
      gsub(/<TD.*?>Passed<\/TD>/,'').
      gsub(/<TD.*?middle.*?>.*?<\/TD>/m,'').
      gsub(/<TD.*?statTextBig.*?>.*?<\/TD>/m,'').
      gsub(/<TR.*?>\s*?<\/TR>/,'').
      gsub(/^\s*$/,"").gsub(/\n+/,"\n").sub(/BORDER="0"/,'BORDER="1"')


    puts "saving test cases, #{@fnParameter} ..."
    open(@fnParameter,"w").write(cnt)
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

  def getParameters fn
    (Hpricot(open(fn,'r').read)/:tr).map {|i| (i/:td).map {|i| i.inner_html}}
  end

  def genMainCode n,definition, parameter
    parText = definition[:parameters].split(",").zip(parameter[0].split("\n")).map do |i,j|
      i =~ /\[\]/ ? "new #{i}#{j}" : j
    end.join
    
    ret = String.new(MAINCODE)
    ret.sub!(/PARAMETER/,parText)
    ret.sub!(/NUMBER/,n.to_s)
    ret.sub!(/CLASSNAME/,definition[:class])
    ret.sub!(/METHODNAME/,definition[:method])
    ret.sub!(/ANSWER/,parameter[1])
    ret.gsub!(/,/,",\n")
    ret
  end

  def genWholeCode definition,parameters
    main = ""
    parameters.length.times do |i|
      main += genMainCode(i,definition,parameters[i])
    end
   
    ret = String.new(WHOLECODE)
    ret.sub!(/CLASSNAME/,@problem[:name])
    ret.sub!(/MAINCODE/,main)
    ret
  end


  def saveSystemTest
    if File.exist?(@fnTestCode)
      puts "Test code, #{@fnTestCode}, exists."
      exit
    end


    unless File.exist?(@fnStatement)
      saveStatement
    end
    df = getDefinition(@fnStatement)

    unless File.exist?(@fnParameter)
      saveSystemTestParam
    end
    pa = getParameters(@fnParameter)

    print "Generating #{@fnTestCode} ..."
    open(@fnTestCode,"w").write(genWholeCode(df,pa))
    puts " Done"
  end


end


options = {}
optparse = OptionParser.new do |opts|
  opts.on('--systemtest') do
    options[:systemtest] = true
  end
# opts.on('-f','--force') do
#   options[:xml] = true
# end
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
  AirSRM.new(options).saveStatement
end

