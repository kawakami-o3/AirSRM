import java.util.*;
public class Test$CLASSNAME$ {
  public static void main(String[] args) {
    try {
$MAINBODY$
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
