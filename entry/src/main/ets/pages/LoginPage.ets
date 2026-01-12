import { AccountViewModel } from '../viewmodel/AccountViewModel';


@Entry
@Component
export struct LoginPage {
  private message: string = 'Login With Huawei ID';
  pageInfos: NavPathStack = new NavPathStack();
  viewModel: AccountViewModel = new AccountViewModel()
  @State handlePopup: boolean = false;
  @Builder popupBuilder() {
    Column({ space: 2 }) {
      Text('Custom Popup').fontSize(10)
    }.width(100).height(50).padding(5)
  }
  build() {
    Navigation(){
      Column() {
        Button(this.message)
          .width('%60')
          .height('20%')
          .borderRadius(10)
          .shadow(8)
          .backgroundColor(Color.Orange).bindPopup(this.handlePopup, {
          message: this.viewModel.message,
          messageOptions: {
            textColor: Color.Red,
            font: {
              size: '14vp',
              style: FontStyle.Italic,
              weight: FontWeight.Bolder
            }
          },
          placement: Placement.Bottom,
          enableArrow: false,
          followTransformOfTarget: true,
          onStateChange: (e) => {
            let timer = setTimeout(() => {
              this.handlePopup = false;
            }, 6000);
            if (!e.isVisible) {
              this.handlePopup = false;
              clearTimeout(timer);
            }
          }
        })
      }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center).width('100%').height('100%').backgroundColor(Color.White).onClick(async () => {
        const result = await this.viewModel.verifyAccount(this.getUIContext())
        if (result) {
          this.pageInfos.pushPath({
            name: 'Index'
          });
        } else {

          this.handlePopup = !this.handlePopup;

        }
      })
    }
  }



}
