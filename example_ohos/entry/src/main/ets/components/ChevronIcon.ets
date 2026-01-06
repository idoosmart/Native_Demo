@Component
export struct ChevronIcon {
  private w: Length = 20;
  private color: ResourceColor = '#888888';
  private strokeWidth: Length = 2;

  build() {
    // We use the Shape component to contain our Path
    Shape() {
      // The Path component draws the chevron shape
      Path()
        .commands('M 2 0 L 8 5 L 2 10') // SVG path data for a '>' shape
        .stroke(this.color)
        .strokeWidth(this.strokeWidth)
        .strokeLineCap(LineCapStyle.Round) // Makes the line ends rounded and look softer
        .strokeLineJoin(LineJoinStyle.Round) // Makes the corner rounded
    }
    .viewPort({ width: 10, height: 10 }) // Defines the coordinate system for the path
    .width(this.w)
    .height(this.w)
  }
}