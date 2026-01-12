import { geoLocationManager } from '@kit.LocationKit';
import LocationUtil from '../utils/LocationUtil';
import LocationService from '../service/LocationService';
import { LocationData } from '../model/LocationData';
import { EventSnapCard } from '../component/EventCard';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { common } from '@kit.AbilityKit';


@Builder
export function PageTwoBuilder(name: string, param: Object) {
  Index()
}

@Entry
@Component
struct Index {
  context=this.getUIContext().getHostContext() as common.UIAbilityContext
  pageInfos: NavPathStack = new NavPathStack();
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
        const granted = await LocationUtil.requestLocationPermissions(this.context);
        if (granted) {

        }
      }
    } catch (error) {

    }

    try {
      let request: geoLocationManager.ContinuousLocationRequest = {
        'interval': 1,
        'locationScenario': geoLocationManager.UserActivityScenario.NAVIGATION
      }
      let locationCallback = (location: geoLocationManager.Location): void => {

      };
      const location = await geoLocationManager.getCurrentLocation();
      geoLocationManager.on('locationChange', request, locationCallback);

      this.currLocation = location
      this.saveLocation('locationLongitude',this.currLocation.longitude)
      this.saveLocation('locationLatitude',this.currLocation.latitude)
    } catch (err) {

    }
    if (this.currLocation?.latitude !== undefined && this.currLocation?.longitude !== undefined) {
      await this.service.getLocations(this.currLocation?.latitude,
        this.currLocation?.longitude,this.context,(datas) => {
        this.datasLocation = datas
      })
      for (let index = 0; index < this.datasLocation.length; index++) {
        const element = this.datasLocation[index];

      }
    }

  }

  saveLocation(key: string, value: number) {
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    util.preferencesPut(preferences, key, value);
  }

  build() {
    Scroll(this.scroll) {
      Column() {
        ForEach(this.datasLocation, (cardModel: LocationData , index:number) => {
          EventSnapCard({ eventName: cardModel.name })
            .width('80%')
            .height(30)
            .borderRadius(8)
            .margin(8)
            .backgroundColor(Color.Orange)
            .align(Alignment.Center)
            .onClick(() => {
              this.pageInfos.pushPath(
                {
                  name: `EventDetail`,
                  param: cardModel
                }
              )

            })
        },(cardModel: LocationData , index:number) => cardModel.name)
      }.width('100%').backgroundColor(Color.White)
    }.scrollable(ScrollDirection.Vertical).scrollBar(0)

  }
}