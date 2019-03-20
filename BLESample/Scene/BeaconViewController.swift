import UIKit
import CoreLocation

class BeaconViewController: UIViewController, CLLocationManagerDelegate {
    
    //beaconの値取得関係の変数
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ロケーションマネージャを作成する
        trackLocationManager = CLLocationManager();
        
        // デリゲートを自身に設定
        trackLocationManager.delegate = self;
        
        // BeaconのUUIDを設定
        let uuid:UUID? = UUID(uuidString: "48534442-4C45-4144-80C0-1800FFFFFFFF")
        
        //Beacon領域を作成
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "net.noumenon-th")
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == CLAuthorizationStatus.notDetermined) {
            trackLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    // 位置認証のステータスが変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //観測を開始させる
        print("didChangeAuthorizatio. \(status.rawValue)")
        trackLocationManager.startMonitoring(for: self.beaconRegion)
    }
    
    // 観測の開始に成功すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        print("didStartMonitoring")
        trackLocationManager.requestState(for: self.beaconRegion)
    }
    
    // 領域内にいるかどうかを判定する
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        print("didDetermineState. \(state)")
        switch (state) {
        case .inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
            trackLocationManager.startRangingBeacons(in: beaconRegion)
            // →(didRangeBeacons)で測定をはじめる
            break
            
        case .outside:
            // 領域外→領域に入った場合はdidEnterRegionが呼ばれる
            break
            
        case .unknown:
            // 不明→領域に入った場合はdidEnterRegionが呼ばれる
            break
            
        }
    }
    
    // 領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // →(didRangeBeacons)で測定をはじめる
        print("didEnterRegion")
        self.trackLocationManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    // 領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //測定を停止する
        print("didExitRegion")
        self.trackLocationManager.stopRangingBeacons(in: self.beaconRegion)
    }
    
    //領域内にいるので測定をする
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        /*
         beaconから取得できるデータ
         proximityUUID   :   regionの識別子
         major           :   識別子１
         minor           :   識別子２
         proximity       :   相対距離
         accuracy        :   精度
         rssi            :   電波強度
         */
        print("didRangeBeacons")
        beacons.forEach {
            print($0)
        }
    }
}
