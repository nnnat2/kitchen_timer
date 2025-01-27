# キッチンタイマーEASY
[キッチンタイマーEASY](https://play.google.com/store/apps/details?id=com.easy.kitchen.timer.app&pli=1)  

簡単に使えるキッチンタイマーです。  
pickerで時間を設定しタイマーを開始します。  
タイマーが終了すると音が鳴り、ローカル通知が来ます。  
設定した時刻とタイマー終了時のアラーム音のON/OFFを初期設定として保存できます。  

## 作ろうと思ったきっかけ
AndroidスマホにプリインストールされているGoogle製の「時計」アプリのタイマー機能が使いにくいと感じたため。  
(時間の入力方法が独特で、時間、分、秒を個別に設定できない)  
  
![altテキスト](https://appllio.com/sites/default/files/styles/portrait_xl_1/public/2022/08/05/r-2208-android-set-timer-4.jpg)  
3分間のタイマーを設定したい場合、「300」と入力しなければならない



## 使用パッケージ

- **flutter_picker**  
- **shared_preferences**  
- **flutter_local_notifications**  
- **just_audio**  
- **change_app_package_name**  
- **flutter_launcher_icon**  
- **flutter_slidable**

## 苦労した点
- flutter_local_notificationsパッケージを使用してローカル通知を飛ばす仕組みの実装  
公式ドキュメントの理解に時間がかかった。  
- インターバルの設定  
  タイマー開始/停止ボタンを1秒以内に連打するとTimerクラスの特性上挙動がおかしくなってしまうため、  
  ボタンを押したときに1秒間のインターバルを設定した。

## アップデート 
- v1.1.0 複数タイマーの追加  
  複数のタイマーを設定可能
- v1.2.0 バックグラウンド対応など  
  flutter_slidableパッケージを使用してリストの削除に対応
  タイマーがバックグラウンドで動くように変更

## ストア画像
![Image](https://github.com/user-attachments/assets/45620452-357d-44a5-9800-4a663d8915b5)

