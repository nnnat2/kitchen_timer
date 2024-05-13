# キッチンタイマーEASY
[キッチンタイマーEASY](https://play.google.com/store/apps/details?id=com.easy.kitchen.timer.app&pli=1)  

簡単に使えるキッチンタイマーです。  
pickerで時間を設定しタイマーを開始します。  
タイマーが終了すると音が鳴り、ローカル通知が来ます。  
設定した時刻とタイマー終了時の音のON/OFFを初期設定として保存できます。  

## 使用パッケージ

- **flutter_picker**  
- **shared_preferences**  
- **flutter_local_notifications**  
- **audioplayer**  
- **change_app_package_name**  
- **flutter_launcher_icon**  

## 苦労した点
- flutter_local_notificationsパッケージを使用してローカル通知を飛ばす仕組みの実装  
公式ドキュメントの理解に時間がかかった。  
- Timerクラスの使用  
  タイマー開始/停止ボタンを1秒以内に連打するとTimerクラスの特性上挙動がおかしくなってしまうため、  
  ボタンを押したときに1秒間のインターバルを設定した。
