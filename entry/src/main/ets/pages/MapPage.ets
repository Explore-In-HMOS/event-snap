import { map, mapCommon, MapComponent, navi } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { LocationData } from '../model/LocationData';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { common } from '@kit.AbilityKit';


@Builder
export function PageThreeBuilder(name: string, param: Object) {
  MapPage()
}


@Entry
@Component
export struct MapPage {
  context=this.getUIContext().getHostContext() as common.UIAbilityContext
  pageInfos: NavPathStack = new NavPathStack();
  private TAG = 'HuaweiMapDemo';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  @LocalStorageProp('locationLongitude') currLocationLongitude: number = 0;
  @LocalStorageProp('locationLatitude') currLocationLatitude: number = 0;
  getParam:LocationData = {
    name:'',
    latitude:0,
    adress:'',
    longitude:0
  }

  private loadPreferences() {
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    this.currLocationLongitude = util.getPreference(preferences, 'locationLongitude', 0) as number;
    this.currLocationLatitude = util.getPreference(preferences, 'locationLatitude', 0) as number;
  }

  aboutToAppear(): void {
    this.loadPreferences()

    // Map initialization parameters used to set the coordinates of the map center point and zoom level.
    this.mapOptions = {
      position: {
        target: {
          latitude: this.currLocationLatitude,
          longitude: this.currLocationLongitude
        },
        zoom: 18
      }
    };

    // Map initialization callback.
    this.callback = async (err, mapController) => {
      if (!err) {
        // Obtain mapController to operate the map.
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info(this.TAG, `on-mapLoad`);
        }
        this.mapEventManager.on('mapLoad', callback);
      } else {
        console.error(`Failed to initialize the map. Code: ${err.code}; message: ${err.message}`);
      }
    };
    this.mapController?.setMyLocationEnabled(true)
    this.mapController?.setMyLocationControlsEnabled(true)

  }

  onPageShow(): void {
    // Switch the map to the foreground.
    if (this.mapController) {
      this.mapController.show();
    }
    this.drawRoute()
  }

  async drawRoute() {
    try {

      let params: navi.DrivingRouteParams = {
        // Longitude and latitude of the departure place.
        origins: [{
          'latitude': this.currLocationLatitude!!,
          'longitude': this.currLocationLongitude!!
        }],
        // Longitude and latitude of the destination.
        destination: {
          'latitude': this.getParam.latitude,
          'longitude': this.getParam.longitude
        },
        // Waypoints on the route.
        language: 'en'
      };
      try {
        const result = await navi.getDrivingRoutes(params);

        let mapRoute = result.routes[0].overviewPolyline

        let polylineOptions: mapCommon.MapPolylineOptions = {
          width: 10.0,
          points: mapRoute!!.map((points) => {

            return { longitude: points.longitude, latitude: points.latitude } as mapCommon.LatLng
          })
        };
        let markerOptions1: mapCommon.MarkerOptions = {
          position: {
            latitude: this.getParam.latitude,
            longitude: this.getParam.longitude
          },
          // The icon must be stored in the resources/base/media directory.
          icon: $r('app.media.finish'),
          anchorU: 0.5,
          anchorV: 0.5,
          visible: true
        };
        let markerOptions2: mapCommon.MarkerOptions = {
          position: {
            latitude: this.currLocationLatitude,
            longitude: this.currLocationLongitude
          },
          // The icon must be stored in the resources/base/media directory.
          icon: $r('app.media.location_target'),
          anchorU: 0.5,
          anchorV: 0.5,
          visible: true
        };
        this.mapController?.addMarker(markerOptions1)
        this.mapController?.addMarker(markerOptions2)
        this.mapController?.addPolyline(polylineOptions)
        console.info(`Succeeded in getting driving routes. result is ${JSON.stringify(result.routes[0])}`);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        console.error(`Succeeded in getting driving routes. Code is ${err.code}, message is ${err.message}`);
      }
    } catch (e) {

    }
  }

  // This is called each time the page is hidden, for example,
  // during page redirection or when the app is switched to the background.
  // It works only for the custom components decorated using @Entry.
  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    NavDestination(){
      Column() {

        Stack({ alignContent:Alignment.Top }) {

          MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
            .width('100%')
            .height('100%')

          Button('Back').width(75).height(25).margin({top:8}).onClick(()=>{
            const data = this.getParam as LocationData
            this.pageInfos.pushPath({
              name:`EventDetail`,
              param:data
            })
          }).backgroundColor(Color.Orange)
        }.width('100%').height('100%')

      }.height('100%').width('%100')
    }.onReady((context:NavDestinationContext)=>{
      this.pageInfos = context.pathStack
      this.getParam.name = (context.pathInfo.param as LocationData).name
      this.getParam.latitude = (context.pathInfo.param as LocationData).latitude
      this.getParam.longitude=(context.pathInfo.param as LocationData).longitude
      this.getParam.adress=(context.pathInfo.param as LocationData).adress
    })
  }
}
