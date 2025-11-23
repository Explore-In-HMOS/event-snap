import { LocationData } from '../model/LocationData';
import { image } from '@kit.ImageKit';

import { generateBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NotificationKitUtils } from '../utils/NotificationKitUtils';


@Entry
@Component
export struct EventDetail {
  getParam = this.getUIContext().getRouter().getParams() as LocationData;
  @State pixelMap: image.PixelMap | undefined = undefined;

  async aboutToAppear() {

    let content =
      `Event Place : ${this.getParam.name} \n Event Adress : ${this.getParam.adress} \n Event longitude : ${this.getParam.longitude} \n Event Latitude : ${this.getParam.latitude}`
    let options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: 400,
      width: 400
    }
    try {
      // Return a PixelMap-format barcode image.
      generateBarcode.createBarcode(content, options, (error: BusinessError, pixelMap: image.PixelMap) => {
        if (error) {
          hilog.error(0x0001, '[generateBarcode]',
            `Failed to get PixelMap by callback with options. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        this.pixelMap = pixelMap;
      })
    } catch (error) {
      hilog.error(0x0001, '[generateBarcode]',
        `Failed to createBarcode by callback with options. Code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    Column() {
      Stack() {
        Image($r('app.media.arrow')).width(32).height(24).objectFit(ImageFit.Contain).onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/Index'
          })
        })
      }.width('60%').align(Alignment.TopStart)

      Text(this.getParam.name).textAlign(TextAlign.Center).width('100%').margin({ top: 4 })
      Image(this.pixelMap).width(75).height(75).objectFit(ImageFit.Contain).margin({ top: 16, bottom: 8 })
      Row() {
        Button('Join Event')
          .onClick(() => {
            const eventNotification = new NotificationKitUtils()
            eventNotification.startNotification(this.getUIContext())
          })
          .width('40%')
          .height(30)
          .margin({ right: 4 })
          .backgroundColor('#0EA5A4')
        Button('Go to map')
          .onClick(() => {
            const data = this.getParam as LocationData
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/MapPage', params: data
            })
          })
          .width('40%')
          .height(30)
          .margin({ left: 4 })
          .backgroundColor('#0EA5A4')
      }.margin({ top: 8 })
    }
    .height('100%')
    .width('%100')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Orange)

  }
}
