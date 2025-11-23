import { site } from '@kit.MapKit';
import { LocationData } from '../model/LocationData';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import LocationUtil from '../utils/LocationUtil';


export default class LocationService {
  private _LocationDatas: Array<LocationData> = [];
  private _isLoading: boolean = false;
  private _locationDatasName: Array<string> = []
  private _currLocation: geoLocationManager.Location | undefined = undefined;

  public set currLocation(value: geoLocationManager.Location | undefined) {
    this._currLocation = value;
  }

  public get currLocation(): geoLocationManager.Location | undefined {
    return this._currLocation;
  }

  public set isLoading(value: boolean) {
    this._isLoading = value;
  }

  public get isLoading(): boolean {
    return this._isLoading;
  }

  private _error: string | null = null;

  public set error(value: string | null) {
    this._error = value;
  }

  public get error(): string | null {
    return this._error;
  }

  public set LocationDatas(value: Array<LocationData>) {
    this._LocationDatas = value;
  }

  public get LocationDatas(): Array<LocationData> {
    return this._LocationDatas;
  }

  async getLocations(lat: number, long: number,
    updateCallback: (locationDatas: Array<LocationData>, isLoading: boolean,
      error: string | null) => void) {
    try {
      const hasPermissions = await LocationUtil.checkLocationPermissions()

      if (hasPermissions) {

      } else {
        const granted = await LocationUtil.requestLocationPermissions();
        if (granted) {

        }
      }
    } catch (error) {

    }
    try {
      let params: site.NearbySearchParams = {
        location: {
          latitude: lat,
          longitude: long
        },
        poiTypes: [
          'RESTAURANT',
          'TURKISH_RESTAURANT'
        ],
        radius: 500,
      }
      // Return the nearby place search result.
      try {
        const result = await site.nearbySearch(params);

        if (result.sites != undefined) {
          console.info(`Succeeded in searching nearby. result is ${JSON.stringify(result.sites[0].name)}`);
          for (let index = 0; index < result.sites.length; index++) {


            if (result.sites[index].location?.latitude != undefined &&
              result.sites[index].location?.longitude != undefined && result.sites[index].name != undefined) {
              const element: LocationData = {
                latitude: result.sites[index].location!!.latitude,
                longitude: result.sites[index].location!!.longitude,
                name: result.sites[index].name || 'undefiend',
                adress: result.sites[index].formatAddress || 'undefined',
              };
              this._LocationDatas[index] = element


              console.info('Succeeded in searching by Data: ', result.sites[index].name, ' , ',
                result.sites[index].formatAddress, result.sites[index].location!!.latitude.toString(), ' long: ',
                result.sites[index].location!!.longitude.toString());
            }
            updateCallback(this._LocationDatas, this._isLoading, this._error)
          }
        } else {

        }
      } catch (error) {
        const err: BusinessError = error as BusinessError;

      }


    } catch (e) {
      this._error = 'Error when loading locations'
      this._isLoading = false

      updateCallback(this._LocationDatas, this._isLoading, this._error)
    }
  }


}

