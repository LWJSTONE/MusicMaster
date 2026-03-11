<template>
  <div class="player-container">
    <!-- 隐藏的音频元素 -->
    <audio ref="audioPlayer" @ended="onSongEnded" @loadedmetadata="onLoadedMetadata" @timeupdate="onTimeUpdate"></audio>
    
    <el-row :gutter="20">
      <!-- 歌手列表 -->
      <el-col :span="6">
        <el-card class="card">
          <div slot="header" class="card-header">
            <span>歌手列表</span>
          </div>
          <div class="singer-list">
            <div v-for="singer in singers" :key="singer.id" class="singer-item" @click="selectSinger(singer)">
              <img :src="singer.pic || defaultPic" class="singer-pic">
              <div class="singer-info">
                <div class="singer-name">{{ singer.name }}</div>
                <div class="singer-meta">{{ singer.location || '未知' }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 歌曲列表 -->
      <el-col :span="12">
        <el-card class="card">
          <div slot="header" class="card-header">
            <span>{{ currentSinger ? currentSinger.name + ' 的歌曲' : '所有歌曲' }}</span>
            <el-button size="small" @click="loadAllSongs" v-if="currentSinger">显示全部</el-button>
          </div>
          <div class="song-list">
            <div v-for="(song, index) in songs" :key="song.id" class="song-item" :class="{ 'playing': currentSong && currentSong.id === song.id }" @click="playSong(song, index)">
              <div class="song-info">
                <div class="song-name">{{ song.name }}</div>
                <div class="song-meta">{{ song.album }} · {{ song.style }} · {{ formatTime(song.duration) }}</div>
              </div>
              <div class="song-actions">
                <el-button size="mini" :icon="currentSong && currentSong.id === song.id && isPlaying ? 'el-icon-video-pause' : 'el-icon-video-play'" circle @click.stop="playSong(song, index)"></el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 歌单列表 -->
      <el-col :span="6">
        <el-card class="card">
          <div slot="header" class="card-header">
            <span>歌单列表</span>
          </div>
          <div class="songlist-list">
            <div v-for="songlist in songlists" :key="songlist.id" class="songlist-item" @click="selectSongList(songlist)">
              <img :src="songlist.pic || defaultPic" class="songlist-pic">
              <div class="songlist-info">
                <div class="songlist-name">{{ songlist.title }}</div>
                <div class="songlist-meta">{{ songlist.songCount }} 首歌 · {{ songlist.collectCount }} 收藏</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 播放器控制栏 -->
    <div class="player-bar" v-if="currentSong">
      <div class="player-info">
        <img :src="currentSong.pic || defaultPic" class="current-pic">
        <div class="current-info">
          <div class="current-name">{{ currentSong.name }}</div>
          <div class="current-singer">{{ currentSong.singerName }}</div>
        </div>
      </div>

      <div class="player-controls">
        <el-button icon="el-icon-refresh-left" circle @click="prevSong"></el-button>
        <el-button :icon="isPlaying ? 'el-icon-video-pause' : 'el-icon-video-play'" circle size="large" @click="togglePlay"></el-button>
        <el-button icon="el-icon-refresh-right" circle @click="nextSong"></el-button>
      </div>

      <div class="player-progress">
        <span>{{ formatTime(currentTime) }}</span>
        <el-slider v-model="progress" @change="seekTo" :disabled="!currentSong" style="flex: 1; margin: 0 15px;"></el-slider>
        <span>{{ formatTime(actualDuration || (currentSong ? currentSong.duration : 0)) }}</span>
      </div>

      <div class="player-volume">
        <i :class="isMuted ? 'el-icon-turn-off-microphone' : 'el-icon-microphone'" @click="toggleMute" style="cursor: pointer;"></i>
        <el-slider v-model="volume" @input="changeVolume" style="width: 100px; margin-left: 10px;"></el-slider>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Player',
  data() {
    return {
      singers: [],
      songs: [],
      songlists: [],
      currentSinger: null,
      currentSong: null,
      currentIndex: -1,
      isPlaying: false,
      currentTime: 0,
      progress: 0,
      volume: 80,
      isMuted: false,
      actualDuration: 0,
      progressInterval: null,
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  mounted() {
    // 初始化音频
    if (this.$refs.audioPlayer) {
      this.$refs.audioPlayer.volume = this.volume / 100
    }
  },
  beforeDestroy() {
    // 清理定时器
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
    }
  },
  created() {
    this.loadData()
  },
  methods: {
    async loadData() {
      try {
        // 加载歌手列表
        const singerRes = await axios.get('/api/singer/all')
        if (singerRes.data.code === 200) {
          this.singers = singerRes.data.data
        }

        // 加载歌曲列表
        this.loadAllSongs()

        // 加载歌单列表
        const songlistRes = await axios.get('/api/song-list/all')
        if (songlistRes.data.code === 200) {
          this.songlists = songlistRes.data.data
        }
      } catch (error) {
        this.$message.error('数据加载失败')
        console.error(error)
      }
    },

    loadAllSongs() {
      axios.get('/api/song/all').then(res => {
        if (res.data.code === 200) {
          this.songs = res.data.data
          this.currentSinger = null
        }
      }).catch(err => {
        this.$message.error('歌曲加载失败')
        console.error(err)
      })
    },

    selectSinger(singer) {
      this.currentSinger = singer
      axios.get(`/api/song/page?current=1&size=100&singerId=${singer.id}`).then(res => {
        if (res.data.code === 200) {
          this.songs = res.data.data.records
        }
      }).catch(err => {
        this.$message.error('歌曲加载失败')
        console.error(err)
      })
    },

    selectSongList(songlist) {
      this.$message.info(`选中歌单: ${songlist.title}`)
    },

    playSong(song, index) {
      if (!song.url) {
        this.$message.warning('该歌曲暂无播放地址')
        return
      }

      this.currentSong = song
      this.currentIndex = index
      this.currentTime = 0
      this.progress = 0

      const audio = this.$refs.audioPlayer
      if (audio) {
        audio.src = song.url
        audio.load()
        audio.play().then(() => {
          this.isPlaying = true
          this.startProgressTracking()
        }).catch(err => {
          console.error('播放失败:', err)
          this.$message.error('播放失败，请检查音频文件')
          this.isPlaying = false
        })
      }
    },

    togglePlay() {
      const audio = this.$refs.audioPlayer
      if (!audio) return

      if (this.isPlaying) {
        audio.pause()
        this.isPlaying = false
        this.stopProgressTracking()
      } else {
        if (!audio.src && this.songs.length > 0) {
          this.playSong(this.songs[0], 0)
        } else {
          audio.play().then(() => {
            this.isPlaying = true
            this.startProgressTracking()
          }).catch(err => {
            console.error('播放失败:', err)
          })
        }
      }
    },

    prevSong() {
      if (this.songs.length > 0 && this.currentIndex > -1) {
        const prevIndex = this.currentIndex > 0 ? this.currentIndex - 1 : this.songs.length - 1
        this.playSong(this.songs[prevIndex], prevIndex)
      }
    },

    nextSong() {
      if (this.songs.length > 0 && this.currentIndex > -1) {
        const nextIndex = this.currentIndex < this.songs.length - 1 ? this.currentIndex + 1 : 0
        this.playSong(this.songs[nextIndex], nextIndex)
      }
    },

    seekTo(value) {
      const audio = this.$refs.audioPlayer
      if (audio && this.actualDuration > 0) {
        const newTime = (value / 100) * this.actualDuration
        audio.currentTime = newTime
        this.currentTime = newTime
      }
    },

    changeVolume(value) {
      const audio = this.$refs.audioPlayer
      if (audio) {
        audio.volume = value / 100
        if (value > 0) {
          this.isMuted = false
        }
      }
    },

    toggleMute() {
      const audio = this.$refs.audioPlayer
      if (audio) {
        this.isMuted = !this.isMuted
        audio.muted = this.isMuted
      }
    },

    onSongEnded() {
      this.isPlaying = false
      this.stopProgressTracking()
      // 自动播放下一首
      this.nextSong()
    },

    onLoadedMetadata() {
      const audio = this.$refs.audioPlayer
      if (audio) {
        this.actualDuration = audio.duration
      }
    },

    onTimeUpdate() {
      const audio = this.$refs.audioPlayer
      if (audio && this.isPlaying) {
        this.currentTime = audio.currentTime
        if (this.actualDuration > 0) {
          this.progress = (audio.currentTime / this.actualDuration) * 100
        }
      }
    },

    startProgressTracking() {
      this.stopProgressTracking()
      this.progressInterval = setInterval(() => {
        const audio = this.$refs.audioPlayer
        if (audio && this.isPlaying) {
          this.currentTime = audio.currentTime
          if (this.actualDuration > 0) {
            this.progress = (audio.currentTime / this.actualDuration) * 100
          }
        }
      }, 100)
    },

    stopProgressTracking() {
      if (this.progressInterval) {
        clearInterval(this.progressInterval)
        this.progressInterval = null
      }
    },

    formatTime(seconds) {
      if (!seconds || isNaN(seconds)) return '00:00'
      const mins = Math.floor(seconds / 60)
      const secs = Math.floor(seconds % 60)
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }
  }
}
</script>

<style scoped>
.player-container {
  padding: 0;
}

.card {
  margin-bottom: 20px;
  height: calc(100vh - 200px);
  overflow-y: auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.singer-list, .song-list, .songlist-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.singer-item, .songlist-item {
  display: flex;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.singer-item:hover, .songlist-item:hover {
  background-color: #f5f5f5;
}

.singer-pic, .songlist-pic, .current-pic {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  margin-right: 15px;
}

.singer-info, .songlist-info {
  flex: 1;
}

.singer-name, .songlist-name, .song-name {
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.singer-meta, .songlist-meta, .song-meta {
  font-size: 12px;
  color: #999;
}

.song-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.song-item:hover {
  background-color: #f5f5f5;
}

.song-item.playing {
  background-color: #e6f7ff;
  border: 1px solid #1890ff;
}

.song-info {
  flex: 1;
}

.song-actions {
  display: flex;
  gap: 10px;
}

.player-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 80px;
  background: linear-gradient(to top, #fff, #f5f5f5);
  border-top: 1px solid #e8e8e8;
  display: flex;
  align-items: center;
  padding: 0 30px;
  gap: 30px;
  z-index: 1000;
}

.player-info {
  display: flex;
  align-items: center;
  width: 250px;
}

.current-pic {
  width: 60px;
  height: 60px;
  border-radius: 6px;
}

.current-info {
  margin-left: 15px;
}

.current-name {
  font-weight: bold;
  margin-bottom: 5px;
}

.current-singer {
  font-size: 12px;
  color: #999;
}

.player-controls {
  display: flex;
  align-items: center;
  gap: 20px;
}

.player-progress {
  display: flex;
  align-items: center;
  flex: 1;
  color: #666;
}

.player-volume {
  display: flex;
  align-items: center;
  width: 150px;
}
</style>
