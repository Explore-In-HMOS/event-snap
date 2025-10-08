
@Component
export struct EventSnapCard {
  @Prop eventName?:string

  build() {
    Column() {
      Text(this.eventName).textOverflow({ overflow: TextOverflow.Ellipsis }).textAlign(TextAlign.Center)
        .maxLines(1)
    }.height(30).width('%80').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }



}
