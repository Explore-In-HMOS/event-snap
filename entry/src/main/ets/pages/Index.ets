import { geoLocationManager } from '@kit.LocationKit';
import LocationUtil from '../utils/LocationUtil';
import LocationService from '../service/LocationService';
import { LocationData } from '../model/LocationData';
import { EventSnapCard } from '../component/EventCard';
import { router } from '@kit.ArkUI';
import { PreferencesUtil } from '../utils/PreferencesUtil';
let context = getContext(this);
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private currLocation: geoLocationManager.Location | undefined = undefined;
  service = new LocationService()
  @State datasLocation: Array<LocationData> = []
  scroll: Scroller = new Scroller()
  scrollAnimation: ScrollAnimationOptions = {
    duration: 0,
    curve: Curve.EaseInOut,
    canOverScroll: true
  }

  async aboutToAppear() {


    try {
      const hasPermissions = await LocationUtil.checkLocationPermissions()

      if (hasPermissions) {

      } else {
        const granted = await LocationUtil.requestLocationPermissions();
        if (granted) {
          console.log('Granted')
        }
      }
    } catch (error) {
      console.error(`Error handling permissions: ${JSON.stringify(error)}`);
    }

    try {
      let request: geoLocationManager.ContinuousLocationRequest = {
        'interval': 1,
        'locationScenario': geoLocationManager.UserActivityScenario.NAVIGATION
      }
      let locationCallback = (location: geoLocationManager.Location): void => {
        console.info('locationCallback: data: ' + JSON.stringify(location));
      };
      const location = await geoLocationManager.getCurrentLocation();
      geoLocationManager.on('locationChange', request, locationCallback);

      this.currLocation = location
      this.saveLocation('locationLongitude',this.currLocation.longitude)
      this.saveLocation('locationLatitude',this.currLocation.latitude)
    } catch (err) {
      console.error('errCode :' + JSON.stringify(err));
    }
    if (this.currLocation?.latitude != undefined && this.currLocation?.longitude != undefined) {
      await this.service.getLocations(this.currLocation?.latitude, this.currLocation?.longitude, (datas) => {
        this.datasLocation = datas
      })
      for (let index = 0; index < this.datasLocation.length; index++) {
        const element = this.datasLocation[index];
        console.log(`Element ${index} : ${element.name} \n`)
      }
    }

  }

  saveLocation(key: string, value: number) {
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(context);
    util.preferencesPut(preferences, key, value);
  }

  build() {
    Scroll(this.scroll) {
      Column() {
        ForEach(this.datasLocation, (cardModel: LocationData) => {
          EventSnapCard({ eventName: cardModel.name })
            .width('80%')
            .height(30)
            .borderRadius(8)
            .margin(8)
            .backgroundColor(Color.Orange)
            .align(Alignment.Center)
            .onClick(() => {
              router.pushUrl({ url: 'pages/EventDetail', params: cardModel })
            })
        })
      }.width('100%').backgroundColor(Color.White)
    }.scrollable(ScrollDirection.Vertical).scrollBar(0)

  }
}