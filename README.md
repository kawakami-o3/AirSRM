[English version here](https://github.com/kawakami-o3/AirSRM/wiki/IntroEnglish) 

# これは何?
Topcoder SRM 練習支援スクリプトです。主な機能は

* 問題文のダウンロード
* 雛形コードの生成（[FileEdit.jar](http://community.topcoder.com/contest/classes/FileEdit/FileEdit.htm)プラグイン形式に準拠）
* システムテストで使用されるパラメータのダウンロード
* システムテスト実行コードの生成
* C++, C#, Java をサポート


# 使い方は?

以下では、Javaでの使用方法を解説します。C++やC#での利用方法はWikiを参照してください。
[github wiki](https://github.com/kawakami-o3/AirSRM/wiki) 

まず、AirSRM.config をエディタで開いて、ユーザ名とパスワードを編集してください。

	username = 'hogehoge'
	password = 'foobar'

問題文をダウンロードするには3つのオプションが必要です。例えば、SRM 525 の Div 2 Easy をダウンロードしたい場合、

* ラウンド回の「525」
* Division の「2」
* 難易度の「1」(Easy)

 となります。実行例は、

	% ruby AirSRM.rb --srm=525 --division=2 --level=1

SRM 525 Div2 Easy の問題名は RainyRoad なので、問題文は RainyRoad.html として保存され、雛形コードは RainyRoad.java として生成されます。難易度のオプションについては、Medium なら 2、Hard なら 3 を与えてください。また、divやlvのように省略することもでき、以下のように実行することも出来ます。

	% ruby AirSRM.rb --srm=525 --div=2 --lv=1
	
次に、システムテストを行う場合は、`--systemtest`オプションを指定します。

	% ruby AirSRM.rb --srm=525 --divivision=2 --level=1 --systemtest
	
これで、システムテストの全パラメータが RainyRoad.systemtest.html として保存され、実行用Javaソースが TestRainyRoad.java として生成されます。RainyRoad.java が完成しているなら、以下のようにしてシステムテストを行うことができます。

	% javac TestRainyRoad.java && java TestRainyRoad

一つでも返り値が間違っていた場合は、"Wrong Answer"のランタイムエラーを吐いて終了します。
なお、TLEやMLEは判定していませんし、返り値がdoubleの場合はエラーとなるため、注意してください。

# 他には?

ウェブアクセス軽減のために、ラウンドリストを tc.xml として保存しています。
これは [Algoritm Data Feeds](http://apps.topcoder.com/wiki/display/tc/Algorithm+Data+Feeds) で
公開されている Argorithm Round List と同じものです。最新のラウンドリストを取得したい場合は、
tc.xmlを削除するか、-fオプションを指定して実行してください。

	% ruby AirSRM.rb --srm=525 --division=2 --level=1 -f

その他の情報については、[github wiki](https://github.com/kawakami-o3/AirSRM/wiki) を参照してください。
