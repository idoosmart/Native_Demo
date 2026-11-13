// MusicPlayerViewModel.ets
// 音乐播放 + 手表联动 ViewModel
// Music playback + watch linkage ViewModel

import { media } from '@kit.MediaKit';
import { Cmds, IDODeviceNotificationModel } from 'protocol_channel';
import { IDOMusicControlParamModel } from 'protocol_channel/src/main/ets/components/model/IDOMusicControlParamModel';
import { IDOMusicOnOffParamModel } from 'protocol_channel/src/main/ets/components/model/IDOMusicOnOffParamModel';
import { IDOBleVoiceParamModel } from 'protocol_channel/src/main/ets/components/model/IDOBleVoiceParamModel';
import BleManager, { AppDelegate } from '../bluetooth/BleManager';
import { common } from '@kit.AbilityKit';

// https://idoosmart.github.io/Native_GitBook/zh/doc/model/IDODeviceNotificationModel.html#05
// 控制事件常量
// Control event constants
const CTRL_MUSIC_PLAY = 551;
const CTRL_MUSIC_PAUSE = 552;
const CTRL_MUSIC_STOP = 553;
const CTRL_MUSIC_PREV = 554;
const CTRL_MUSIC_NEXT = 555;
const CTRL_VOLUME_UP = 558;
const CTRL_VOLUME_DOWN = 559;
const CTRL_DEV_VOLUME_CHANGED = 565;

/** 歌曲信息 */
/** Song info */
export interface SongInfo {
  name: string;
  singer: string;
  rawFileName: string;
}

/** 播放列表 */
/** Playlist */
const PLAYLIST: SongInfo[] = [
  { name: 'Demo Song 1', singer: 'Artist A', rawFileName: 'demo_song_1.mp3' },
  { name: 'Demo Song 2', singer: 'Artist B', rawFileName: 'demo_song_2.mp3' },
  { name: 'Demo Song 3', singer: 'Artist C', rawFileName: 'demo_song_3.mp3' },
];

@ObservedV2
export class MusicPlayerViewModel {
  // UI 状态
  // UI state
  @Trace isPlaying: boolean = false;
  @Trace currentIndex: number = 0;
  @Trace currentSongName: string = PLAYLIST[0].name;
  @Trace currentSinger: string = PLAYLIST[0].singer;
  @Trace currentTimeMs: number = 0;
  @Trace totalTimeMs: number = 0;
  @Trace consoleLog: string = '';
  @Trace volume: number = 50;
  @Trace maxVolume: number = 15;

  private avPlayer: media.AVPlayer | null = null;
  private context: common.UIAbilityContext;
  private appDelegate: AppDelegate;
  private progressTimer: number = -1;
  private pendingPlay: boolean = false;
  private volumeDebounceTimer: number = -1;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    // 注册设备通知监听
    // Register the device notification listener
    this.appDelegate = {
      listenDeviceNotification: (model: IDODeviceNotificationModel): void => {
        this.onDeviceNotification(model);
      }
    };
    BleManager.registerBleDelegate(this.appDelegate);
    this.initVolume();
    this.initPlayer();
  }

  /** 初始化 AVPlayer */
  /** Initialize AVPlayer */
  private async initPlayer(): Promise<void> {
    try {
      console.info('[MusicVM] initPlayer start');
      this.avPlayer = await media.createAVPlayer();
      console.info('[MusicVM] AVPlayer created, state: ' + this.avPlayer.state);
      this.setupPlayerCallbacks();
      this.log('AVPlayer 初始化成功 / initialization succeeded');
      // 通知手表音乐功能已开启
      // Notify the watch that the music feature is on
      this.sendMusicOnOff(true);
      await this.loadCurrentSong();
    } catch (e) {
      console.error('[MusicVM] initPlayer error: ' + JSON.stringify(e));
      this.log(`AVPlayer 初始化失败 / initialization failed: ${e}`);
    }
  }

  /** 设置播放器回调 */
  /** Set up player callbacks */
  private setupPlayerCallbacks(): void {
    if (!this.avPlayer) return;

    this.avPlayer.on('stateChange', (state: string) => {
      console.info('[MusicVM] stateChange: ' + state + ', pendingPlay: ' + this.pendingPlay);
      this.log(`播放器状态 / Player state: ${state}`);
      switch (state) {
        case 'playing':
          this.isPlaying = true;
          this.totalTimeMs = this.avPlayer?.duration ?? 0;
          this.startProgressTimer();
          this.syncToWatch();
          break;
        case 'paused':
          this.isPlaying = false;
          this.stopProgressTimer();
          this.syncToWatch();
          break;
        case 'stopped':
        case 'idle':
          console.info('[MusicVM] state idle/stopped, resetting');
          this.isPlaying = false;
          this.currentTimeMs = 0;
          this.stopProgressTimer();
          break;
        case 'completed':
          this.isPlaying = false;
          this.stopProgressTimer();
          this.playNext();
          break;
        case 'initialized':
          console.info('[MusicVM] initialized, calling prepare()');
          this.avPlayer?.prepare();
          break;
        case 'prepared':
          this.totalTimeMs = this.avPlayer?.duration ?? 0;
          console.info('[MusicVM] prepared, duration: ' + this.totalTimeMs + ', pendingPlay: ' + this.pendingPlay);
          this.log(`准备完成, 时长 / Prepared, duration: ${Math.floor(this.totalTimeMs / 1000)}s`);
          if (this.pendingPlay) {
            this.pendingPlay = false;
            console.info('[MusicVM] auto-play after prepared');
            this.play();
          }
          break;
        default:
          break;
      }
    });

    this.avPlayer.on('error', (err) => {
      console.error('[MusicVM] player error: ' + err.message);
      this.log(`播放错误 / Playback error: ${err.message}`);
      this.isPlaying = false;
    });
  }

  /** 加载当前歌曲 */
  /** Load the current song */
  private async loadCurrentSong(): Promise<void> {
    if (!this.avPlayer) {
      console.error('[MusicVM] loadCurrentSong: avPlayer is null');
      return;
    }

    const song = PLAYLIST[this.currentIndex];
    this.currentSongName = song.name;
    this.currentSinger = song.singer;
    this.currentTimeMs = 0;

    try {
      console.info('[MusicVM] loadCurrentSong: resetting player, current state: ' + this.avPlayer.state);
      // 重置播放器
      // Reset the player
      await this.avPlayer.reset();
      console.info('[MusicVM] reset done, state: ' + this.avPlayer.state);

      // 从 rawfile 加载
      // Load from rawfile
      const resourceManager = this.context.resourceManager;
      const fd = await resourceManager.getRawFd(song.rawFileName);
      console.info('[MusicVM] getRawFd ok: fd=' + fd.fd + ', offset=' + fd.offset + ', length=' + fd.length);

      this.avPlayer.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length,
      };
      console.info('[MusicVM] fdSrc set, waiting for initialized -> prepared');

      this.log(`加载歌曲 / Loading song: ${song.name} - ${song.singer}`);
    } catch (e) {
      console.error('[MusicVM] loadCurrentSong error: ' + JSON.stringify(e));
      this.log(`加载歌曲失败 / Failed to load song: ${e}`);
    }
  }

  // ======================== 播放控制 ========================
  // ======================== Playback control ========================

  /** 播放 */
  /** Play */
  async play(): Promise<void> {
    if (!this.avPlayer) return;
    try {
      console.info('[MusicVM] play() called, current state: ' + this.avPlayer.state);
      await this.avPlayer.play();
      this.log('▶ 播放 / Play');
    } catch (e) {
      console.error('[MusicVM] play() error: ' + JSON.stringify(e));
      this.log(`播放失败 / Failed to play: ${e}`);
    }
  }

  /** 暂停 */
  /** Pause */
  async pause(): Promise<void> {
    if (!this.avPlayer) return;
    try {
      await this.avPlayer.pause();
      this.log('⏸ 暂停 / Pause');
    } catch (e) {
      this.log(`暂停失败 / Failed to pause: ${e}`);
    }
  }

  /** 播放/暂停切换 */
  /** Toggle play/pause */
  async togglePlay(): Promise<void> {
    if (this.isPlaying) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  /** 下一首 */
  /** Next song */
  async playNext(): Promise<void> {
    this.currentIndex = (this.currentIndex + 1) % PLAYLIST.length;
    this.pendingPlay = true;
    await this.loadCurrentSong();
    this.log('⏭ 下一首 / Next');
  }

  /** 上一首 */
  /** Previous song */
  async playPrev(): Promise<void> {
    this.currentIndex = (this.currentIndex - 1 + PLAYLIST.length) % PLAYLIST.length;
    this.pendingPlay = true;
    await this.loadCurrentSong();
    this.log('⏮ 上一首 / Previous');
  }

  /** 进度拖动 */
  /** Seek (progress drag) */
  async seekTo(timeMs: number): Promise<void> {
    if (!this.avPlayer) return;
    try {
      await this.avPlayer.seek(timeMs);
      this.currentTimeMs = timeMs;
    } catch (e) {
      this.log(`Seek 失败 / failed: ${e}`);
    }
  }

  // ======================== 手表联动 ========================
  // ======================== Watch linkage ========================

  /** 同步当前播放状态到手表 */
  /** Sync the current playback state to the watch */
  private syncToWatch(): void {
    const status = this.isPlaying ? 1 : 2; // 1=播放, 2=暂停 / play, 2=pause
    const curSec = Math.floor(this.currentTimeMs / 1000);
    const totalSec = Math.floor(this.totalTimeMs / 1000);

    const param = new IDOMusicControlParamModel(
      status,
      curSec,
      totalSec,
      this.currentSongName,
      this.currentSinger
    );

    Cmds.musicControl(param, (result) => {
      if (result.success) {
        this.log(`→ 手表同步: ${this.isPlaying ? '播放' : '暂停 / Watch sync: ${this.isPlaying ? 'playing' : 'paused'} ${this.currentSongName}`);
      }
    });
  }

  /** 设置手表音乐开关 */
  /** Set the watch music switch */
  private sendMusicOnOff(isOn: boolean): void {
    const param = new IDOMusicOnOffParamModel(isOn ? 1 : 0, isOn ? 1 : 0);
    Cmds.setMusicOnOff(param, (result) => {
      this.log(`→ 手表音乐${isOn ? '开启' : '关闭 / Watch music ${isOn ? 'on' : 'off'}: ${result.success}`);
    });
  }

  /** 通知手表音乐开始/停止 */
  /** Notify the watch of music start/stop */
  private sendMusicStartStop(start: boolean): void {
    if (start) {
      Cmds.musicStart((result) => {
        this.log(`→ 手表 / Watch MusicStart: ${result.success}`);
      });
    } else {
      Cmds.musicStop((result) => {
        this.log(`→ 手表 / Watch MusicStop: ${result.success}`);
      });
    }
  }

  /** 处理手表发来的控制事件 */
  /** Handle control events sent by the watch */
  private onDeviceNotification(model: IDODeviceNotificationModel): void {
    const evt = model.controlEvt;
    if (evt == null || evt === 0) return;

    this.log(`← 手表事件 / Watch event: controlEvt=${evt}`);

    switch (evt) {
      case CTRL_MUSIC_PLAY:
        this.play();
        break;
      case CTRL_MUSIC_PAUSE:
        this.pause();
        break;
      case CTRL_MUSIC_STOP:
        this.pause(); // 停止当作暂停处理 / Treat stop as pause
        break;
      case CTRL_MUSIC_PREV:
        this.playPrev();
        break;
      case CTRL_MUSIC_NEXT:
        this.playNext();
        break;
      case CTRL_VOLUME_UP:
        this.volumeUp();
        break;
      case CTRL_VOLUME_DOWN:
        this.volumeDown();
        break;
      case CTRL_DEV_VOLUME_CHANGED:
        try {
          const json: Record<string, number> = JSON.parse(model.controlJson ?? '{}');
          const pct = json['volume_percentage'] ?? this.volume;
          this.log(`← 手表音量 / Watch volume: ${pct}%`);
          this.setVolume(pct);
        } catch (e) {
          console.error('[MusicVM] parse volume json error: ' + e);
        }
        break;
      default:
        break;
    }
  }

  // ======================== 音量控制 ========================
  // ======================== Volume control ========================

  /** 初始化音量 (AVPlayer 自身音量 0~1) */
  /** Initialize volume (AVPlayer native volume is 0~1) */
  private initVolume(): void {
    this.maxVolume = 100;
    this.volume = 100; // 默认满音量 / Full volume by default
    this.log(`音量 / Volume: ${this.volume}%`);
  }

  /** 音量+ */
  /** Volume+ */
  volumeUp(): void {
    this.setVolume(Math.min(this.volume + 10, this.maxVolume));
  }

  /** 音量- */
  /** Volume- */
  volumeDown(): void {
    this.setVolume(Math.max(this.volume - 10, 0));
  }

  /** 设置音量 (0~100) */
  /** Set volume (0~100) */
  setVolume(val: number): void {
    this.volume = val;
    if (this.avPlayer) {
      this.avPlayer.setVolume(val / 100);
    }
    // 同步音量到设备
    // Sync volume to the device
    // 防抖：停止拖动 300ms 后再发 BLE
    // Debounce: wait 300ms after dragging stops before sending over BLE
    if (this.volumeDebounceTimer !== -1) {
      clearTimeout(this.volumeDebounceTimer);
    }
    this.volumeDebounceTimer = setTimeout(() => {
      this.volumeDebounceTimer = -1;
      const param = new IDOBleVoiceParamModel(this.maxVolume, val);
      Cmds.setBleVoice(param, (result) => {
        console.info(`[MusicVM] setBleVoice: ${result.success}`);
      });
    }, 300);
    console.info(`[MusicVM] setVolume: ${val}%`);
    this.log(`音量 / Volume: ${val}%`);
  }

  // ======================== 辅助方法 ========================
  // ======================== Helper methods ========================

  /** 启动进度定时器 */
  /** Start the progress timer */
  private startProgressTimer(): void {
    this.stopProgressTimer();
    this.progressTimer = setInterval(() => {
      if (this.avPlayer && this.isPlaying) {
        this.currentTimeMs = this.avPlayer.currentTime ?? 0;
      }
    }, 1000);
  }

  /** 停止进度定时器 */
  /** Stop the progress timer */
  private stopProgressTimer(): void {
    if (this.progressTimer !== -1) {
      clearInterval(this.progressTimer);
      this.progressTimer = -1;
    }
  }

  /** 格式化时间 (ms -> mm:ss) */
  /** Format time (ms -> mm:ss) */
  formatTime(ms: number): string {
    const totalSec = Math.floor(ms / 1000);
    const min = Math.floor(totalSec / 60);
    const sec = totalSec % 60;
    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
  }

  /** 追加日志 */
  /** Append a log line */
  private log(msg: string): void {
    const now = new Date();
    const time = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString()
      .padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
    this.consoleLog = `[${time}] ${msg}\n${this.consoleLog}`;
  }

  /** 销毁资源 */
  /** Release resources */
  async destroy(): Promise<void> {
    this.stopProgressTimer();
    BleManager.unregisterBleDelegate(this.appDelegate);
    // 通知手表音乐已关闭
    // Notify the watch that music is off
    this.sendMusicOnOff(false);
    this.sendMusicStartStop(false);
    if (this.avPlayer) {
      await this.avPlayer.release();
      this.avPlayer = null;
    }
    this.log('资源已释放 / Resources released');
  }

  /** 获取播放列表 */
  /** Get the playlist */
  getPlaylist(): SongInfo[] {
    return PLAYLIST;
  }
}
