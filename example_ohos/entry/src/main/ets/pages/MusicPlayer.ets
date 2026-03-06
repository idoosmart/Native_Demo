// MusicPlayer.ets
// 音乐播放 + 手表联动示例页面

import { NavStackModel } from '../viewmodel/NavStackModel';
import { MusicPlayerViewModel, SongInfo } from '../viewmodel/MusicPlayerViewModel';
import { common } from '@kit.AbilityKit';

@Builder
export function MusicPlayerPageBuilder(name: string, navInfo: NavStackModel) {
  MusicPlayerPage()
}

@ComponentV2
struct MusicPlayerPage {
  private vm: MusicPlayerViewModel | null = null;

  aboutToAppear() {
    this.vm = new MusicPlayerViewModel(getContext(this) as common.UIAbilityContext);
  }

  aboutToDisappear() {
    this.vm?.destroy();
  }

  build() {
    NavDestination() {
      Column() {
        // === 歌曲信息 ===
        Column({ space: 4 }) {
          Text(this.vm?.currentSongName ?? '-')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.vm?.currentSinger ?? '-')
            .fontSize(15)
            .fontColor('#888888')
            .maxLines(1)
        }
        .width('100%')
        .padding({ top: 30, bottom: 16, left: 24, right: 24 })
        .alignItems(HorizontalAlign.Center)

        // === 进度条 ===
        Column({ space: 6 }) {
          Slider({
            value: this.vm?.currentTimeMs ?? 0,
            min: 0,
            max: Math.max(this.vm?.totalTimeMs ?? 1, 1),
            step: 1000,
          })
            .width('100%')
            .blockColor('#4A90D9')
            .trackColor('#E0E0E0')
            .selectedColor('#4A90D9')
            .onChange((value: number) => {
              this.vm?.seekTo(value);
            })

          Row() {
            Text(this.vm?.formatTime(this.vm?.currentTimeMs ?? 0) ?? '00:00')
              .fontSize(12).fontColor('#999999')
            Blank()
            Text(this.vm?.formatTime(this.vm?.totalTimeMs ?? 0) ?? '00:00')
              .fontSize(12).fontColor('#999999')
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        // === 播放控制按钮 ===
        Row({ space: 24 }) {
          // 上一首
          Button('⏮')
            .width(56).height(56)
            .fontSize(24)
            .type(ButtonType.Circle)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .onClick(() => this.vm?.playPrev())

          // 播放/暂停
          Button(this.vm?.isPlaying ? '⏸' : '▶')
            .width(72).height(72)
            .fontSize(28)
            .type(ButtonType.Circle)
            .backgroundColor('#4A90D9')
            .fontColor('#FFFFFF')
            .onClick(() => this.vm?.togglePlay())

          // 下一首
          Button('⏭')
            .width(56).height(56)
            .fontSize(24)
            .type(ButtonType.Circle)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .onClick(() => this.vm?.playNext())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 20, bottom: 12 })

        // === 音量控制 ===
        Row({ space: 8 }) {
          Text('🔉')
            .fontSize(16)
            .onClick(() => this.vm?.volumeDown())

          Slider({
            value: this.vm?.volume ?? 0,
            min: 0,
            max: Math.max(this.vm?.maxVolume ?? 15, 1),
            step: 1,
          })
            .layoutWeight(1)
            .blockColor('#666666')
            .trackColor('#E0E0E0')
            .selectedColor('#888888')
            .onChange((value: number) => {
              this.vm?.setVolume(Math.round(value));
            })

          Text('🔊')
            .fontSize(16)
            .onClick(() => this.vm?.volumeUp())
        }
        .width('90%')
        .padding({ bottom: 12 })

        // === 播放列表 ===
        Column() {
          Text('播放列表')
            .fontSize(14)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: 12, bottom: 8 })

          ForEach(this.vm?.getPlaylist() ?? [], (song: SongInfo,
            index: number) => {
            Row() {
              Column({ space: 2 }) {
                Text(song.name)
                  .fontSize(14)
                  .fontColor(index === this.vm?.currentIndex ? '#4A90D9' : '#333333')
                  .fontWeight(index === this.vm?.currentIndex ? FontWeight.Bold : FontWeight.Normal)
                Text(song.singer)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              if (index === this.vm?.currentIndex && this.vm?.isPlaying) {
                Text('♪')
                  .fontSize(16)
                  .fontColor('#4A90D9')
              }
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor(index === this.vm?.currentIndex ? '#F0F6FF' : Color.Transparent)
            .borderRadius(8)
          })
        }
        .width('90%')
        .padding(8)
        .backgroundColor($r('app.color.component_bg'))
        .borderRadius(12)

        // === 日志区域 ===
        Column() {
          Text('SDK 日志')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
            .padding({ left: 4, bottom: 4 })

          Scroll() {
            Text(this.vm?.consoleLog ?? '')
              .fontSize(11)
              .fontColor('#666666')
              .width('100%')
              .padding(8)
              .textAlign(TextAlign.Start)
          }
          .height(120)
          .width('100%')
          .backgroundColor($r('app.color.component_bg'))
          .borderRadius(8)
          .border({ width: 1, color: $r('app.color.divider_color') })
        }
        .width('90%')
        .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_bg'))
    }
    .title('音乐控制')
  }
}
