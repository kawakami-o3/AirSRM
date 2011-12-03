# これは何?
Topcoder の過去問およびシステムテストの内容をダウンロードするスクリプトです。また、システムテストを行えるように、テストコードを生成します。

# 使い方は?
まず、AirSRM.rb をエディタで開いて、ユーザ名とパスワードを編集してください。

	USERNAME = 'hogehoge'
	PASSWORD = 'foobar'

問題文をダウンロードするには3つのオプションが必要です。例えば、SRM 525 の Div 2 Easy をダウンロードしたい場合、ラウンド回の 525、Division の 2、難易度の 1 (Easy) となります。実行例は、

	% ruby AirSRM.rb --srm=525 --division=2 --level=1

SRM 525 Div2 Easy の問題名は RainyRoad なので、問題文は RainyRoad.html として保存されます。難易度のオプションについては、Medium なら 2、Hard なら 3 を与えてください。また、divやlvのように省略することもでき、以下のように実行することも出来ます。

	% ruby AirSRM.rb --srm=525 --div=2 --lv=1
	
次に、システムテストを行う場合は、`--systemtest`オプションを指定します。

	% ruby AirSRM.rb --srm=525 --divivision=2 --level=1 --systemtest
	
これで、システムテストの全パラメータが RainyRoad.systemtest.html として保存され、実行用Javaソースが TestRainyRoad.java として生成されます。RainyRoad.java が完成しているなら、以下のようにしてシステムテストを行うことができます。

	% javac TestRainyRoad.java && java TestRainyRoad

一つでも返り値が間違っていた場合は、"Wrong Answer"のランタイムエラーを吐いて終了します。
なお、TLEやMLEは判定していませんし、返り値がdoubleの場合はエラーとなるため、注意してください。