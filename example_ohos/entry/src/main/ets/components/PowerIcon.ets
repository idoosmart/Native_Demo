// entry/src/main/ets/components/PowerIcon.ets

@Component
export struct PowerIcon {
  private w: Length = 28;
  private color: ResourceColor = '#000000';
  private strokeWidth: Length = 2;

  build() {
    Shape() {
      Path()
        .commands('M 5 2.5 A 3.5 3.5 0 1 1 5 2.4 M 5 1 L 5 5')
        .stroke(this.color)
        .strokeWidth(this.strokeWidth)
        .strokeLineCap(LineCapStyle.Round)
    }
    .viewPort({ width: 10, height: 10 })
    .width(this.w)
    .height(this.w)
  }
}