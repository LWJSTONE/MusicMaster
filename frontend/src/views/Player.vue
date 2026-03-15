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
            <div>
              <el-button size="small" @click="loadAllSongs" v-if="currentSinger" style="margin-right: 10px;">显示全部</el-button>
              <el-button size="small" type="primary" @click="showUploadDialog">上传音乐</el-button>
            </div>
          </div>
          <div class="song-list">
            <div v-for="(song, index) in songs" :key="song.id" class="song-item" :class="{ 'playing': currentSong && currentSong.id === song.id }" @click="playSong(song, index)">
              <div class="song-info">
                <div class="song-name">{{ song.name }}</div>
                <div class="song-meta">{{ song.album }} · {{ song.style }} · {{ formatTime(song.duration) }}</div>
              </div>
              <div class="song-actions">
                <el-button 
                  size="mini" 
                  :type="collectedSongs.includes(song.id) ? 'danger' : 'default'"
                  :icon="collectedSongs.includes(song.id) ? 'el-icon-star-on' : 'el-icon-star-off'"
                  @click.stop="toggleSongCollect(song)"
                  circle>
                </el-button>
                <el-button size="mini" :icon="currentSong && currentSong.id === song.id && isPlaying ? 'el-icon-video-pause' : 'el-icon-video-play'" circle @click.stop="playSong(song, index)"></el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 歌单列表和评论区 -->
      <el-col :span="6">
        <el-card class="card songlist-card">
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
              <el-button 
                size="mini" 
                :type="collectedSongLists.includes(songlist.id) ? 'danger' : 'primary'"
                :icon="collectedSongLists.includes(songlist.id) ? 'el-icon-star-on' : 'el-icon-star-off'"
                @click.stop="toggleCollect(songlist)"
                style="margin-left: auto;">
                {{ collectedSongLists.includes(songlist.id) ? '已收藏' : '收藏' }}
              </el-button>
            </div>
          </div>
        </el-card>

        <!-- 评论区 -->
        <el-card class="card comment-card" v-if="currentSong">
          <div slot="header" class="card-header">
            <span>评论 ({{ comments.length }})</span>
          </div>
          <div class="comment-section">
            <!-- 发表评论 -->
            <div class="comment-input">
              <el-input
                type="textarea"
                v-model="newComment"
                placeholder="发表评论..."
                :rows="2"
                maxlength="200"
                show-word-limit>
              </el-input>
              <el-button type="primary" size="small" @click="submitComment" :disabled="!newComment.trim()" style="margin-top: 10px;">发表评论</el-button>
            </div>
            <!-- 评论列表 -->
            <div class="comment-list">
              <div v-for="comment in comments" :key="comment.id" class="comment-item">
                <div class="comment-avatar">
                  <img :src="comment.avatar || defaultPic">
                </div>
                <div class="comment-content">
                  <div class="comment-user">{{ comment.username }}</div>
                  <div class="comment-text">{{ comment.content }}</div>
                  <div class="comment-meta">
                    <span>{{ formatDate(comment.createTime) }}</span>
                    <el-button type="text" size="mini" @click="likeComment(comment)">
                      <i class="el-icon-thumb"></i> {{ comment.up || 0 }}
                    </el-button>
                  </div>
                </div>
              </div>
              <div v-if="comments.length === 0" class="no-comment">
                暂无评论，快来发表第一条评论吧~
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

    <!-- 上传音乐对话框 -->
    <el-dialog title="上传音乐" :visible.sync="uploadDialogVisible" width="600px">
      <el-form :model="uploadForm" :rules="uploadRules" ref="uploadForm" label-width="80px">
        <el-form-item label="歌曲名称" prop="name">
          <el-input v-model="uploadForm.name" placeholder="请输入歌曲名称"></el-input>
        </el-form-item>
        <el-form-item label="歌手" prop="singerId">
          <el-select v-model="uploadForm.singerId" placeholder="请选择歌手" @change="handleUploadSingerChange" style="width: 100%;">
            <el-option
              v-for="singer in singers"
              :key="singer.id"
              :label="singer.name"
              :value="singer.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="专辑">
          <el-input v-model="uploadForm.album" placeholder="请输入专辑名称"></el-input>
        </el-form-item>
        <el-form-item label="风格">
          <el-input v-model="uploadForm.style" placeholder="如：流行、摇滚、民谣"></el-input>
        </el-form-item>
        <el-form-item label="语言">
          <el-input v-model="uploadForm.language" placeholder="如：国语、英语、日语"></el-input>
        </el-form-item>
        <el-form-item label="封面图片">
          <el-upload
            class="cover-uploader"
            action="/api/song/pic"
            :show-file-list="false"
            :on-success="handleCoverSuccess"
            :before-upload="beforeCoverUpload">
            <img v-if="uploadForm.pic" :src="uploadForm.pic" class="cover-preview">
            <i v-else class="el-icon-plus cover-uploader-icon"></i>
          </el-upload>
        </el-form-item>
        <el-form-item label="音乐文件" prop="url">
          <el-upload
            class="music-uploader"
            action="/api/song/upload"
            :show-file-list="false"
            :on-success="handleMusicSuccess"
            :before-upload="beforeMusicUpload"
            :file-list="musicFileList">
            <el-button size="small" type="primary">
              <i class="el-icon-upload2"></i> 选择音乐文件
            </el-button>
            <div slot="tip" class="el-upload__tip">支持 MP3、WAV、OGG、M4A 格式，最大 50MB</div>
          </el-upload>
          <div v-if="uploadForm.url" class="music-uploaded">
            <i class="el-icon-success" style="color: #67C23A;"></i>
            <span>音乐文件已上传</span>
          </div>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitUpload" :loading="uploading">确定上传</el-button>
      </span>
    </el-dialog>
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
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg',
      // 评论相关
      comments: [],
      newComment: '',
      // 收藏相关
      collectedSongLists: [],
      collectedSongs: [],
      // 上传相关
      uploadDialogVisible: false,
      uploading: false,
      musicFileList: [],
      uploadForm: {
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      },
      uploadRules: {
        name: [
          { required: true, message: '请输入歌曲名称', trigger: 'blur' }
        ],
        singerId: [
          { required: true, message: '请选择歌手', trigger: 'change' }
        ],
        url: [
          { required: true, message: '请上传音乐文件', trigger: 'change' }
        ]
      }
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

        // 加载用户收藏状态
        this.loadCollectedSongLists()
        this.loadCollectedSongs()
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

    // 收藏相关方法
    loadCollectedSongLists() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        return
      }

      axios.get('/api/collect/page', {
        params: {
          current: 1,
          size: 100,
          userId: user.id,
          type: 0
        }
      }).then(res => {
        if (res.data.code === 200) {
          this.collectedSongLists = res.data.data.records.map(item => item.songListId)
        }
      }).catch(err => {
        console.error('加载歌单收藏状态失败:', err)
      })
    },

    loadCollectedSongs() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        return
      }

      axios.get('/api/collect/page', {
        params: {
          current: 1,
          size: 500,
          userId: user.id,
          type: 1
        }
      }).then(res => {
        if (res.data.code === 200) {
          this.collectedSongs = res.data.data.records.map(item => item.songId)
        }
      }).catch(err => {
        console.error('加载歌曲收藏状态失败:', err)
      })
    },

    toggleSongCollect(song) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      const isCollected = this.collectedSongs.includes(song.id)

      if (isCollected) {
        // 取消收藏
        this.$confirm('确定要取消收藏该歌曲吗?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          axios.delete('/api/collect/song', {
            params: {
              userId: user.id,
              songId: song.id
            }
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success('取消收藏成功')
              // 更新收藏状态
              this.collectedSongs = this.collectedSongs.filter(id => id !== song.id)
              // 更新歌曲收藏数
              song.collectCount = Math.max(0, (song.collectCount || 0) - 1)
            } else {
              this.$message.error(res.data.message || '取消收藏失败')
            }
          }).catch(err => {
            this.$message.error('取消收藏失败')
            console.error(err)
          })
        }).catch(() => {})
      } else {
        // 添加收藏
        axios.post('/api/collect/song', {
          userId: user.id,
          songId: song.id
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('收藏成功')
            // 更新收藏状态
            this.collectedSongs.push(song.id)
            // 更新歌曲收藏数
            song.collectCount = (song.collectCount || 0) + 1
          } else {
            this.$message.error(res.data.message || '收藏失败')
          }
        }).catch(err => {
          this.$message.error('收藏失败')
          console.error(err)
        })
      }
    },

    toggleCollect(songlist) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      const isCollected = this.collectedSongLists.includes(songlist.id)

      if (isCollected) {
        // 取消收藏
        this.$confirm('确定要取消收藏该歌单吗?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          axios.delete('/api/collect/songlist', {
            params: {
              userId: user.id,
              songListId: songlist.id
            }
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success('取消收藏成功')
              // 更新收藏状态
              this.collectedSongLists = this.collectedSongLists.filter(id => id !== songlist.id)
              // 更新歌单收藏数
              songlist.collectCount = Math.max(0, (songlist.collectCount || 0) - 1)
            } else {
              this.$message.error(res.data.message || '取消收藏失败')
            }
          }).catch(err => {
            this.$message.error('取消收藏失败')
            console.error(err)
          })
        }).catch(() => {})
      } else {
        // 添加收藏
        axios.post('/api/collect/songlist', {
          userId: user.id,
          songListId: songlist.id
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('收藏成功')
            // 更新收藏状态
            this.collectedSongLists.push(songlist.id)
            // 更新歌单收藏数
            songlist.collectCount = (songlist.collectCount || 0) + 1
          } else {
            this.$message.error(res.data.message || '收藏失败')
          }
        }).catch(err => {
          this.$message.error('收藏失败')
          console.error(err)
        })
      }
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

      // 加载歌曲评论
      this.loadComments(song.id)
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
    },

    // 评论相关方法
    loadComments(songId) {
      axios.get('/api/comment/page', {
        params: {
          current: 1,
          size: 50,
          songId: songId
        }
      }).then(res => {
        if (res.data.code === 200) {
          this.comments = res.data.data.records || []
        }
      }).catch(err => {
        console.error('加载评论失败:', err)
        this.comments = []
      })
    },

    submitComment() {
      if (!this.newComment.trim()) {
        this.$message.warning('请输入评论内容')
        return
      }

      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      const comment = {
        userId: user.id,
        username: user.nickname || user.username,
        avatar: user.avatar || '',
        songId: this.currentSong.id,
        type: 0, // 歌曲评论
        content: this.newComment.trim()
      }

      axios.post('/api/comment', comment).then(res => {
        if (res.data.code === 200) {
          this.$message.success('评论成功')
          this.newComment = ''
          this.loadComments(this.currentSong.id)
        } else {
          this.$message.error(res.data.message || '评论失败')
        }
      }).catch(err => {
        this.$message.error('评论失败')
        console.error(err)
      })
    },

    likeComment(comment) {
      axios.post(`/api/comment/up/${comment.id}`).then(res => {
        if (res.data.code === 200) {
          comment.up = (comment.up || 0) + 1
          this.$message.success('点赞成功')
        }
      }).catch(err => {
        console.error('点赞失败:', err)
      })
    },

    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      const now = new Date()
      const diff = now - date
      const minutes = Math.floor(diff / 60000)
      const hours = Math.floor(diff / 3600000)
      const days = Math.floor(diff / 86400000)

      if (minutes < 1) return '刚刚'
      if (minutes < 60) return `${minutes}分钟前`
      if (hours < 24) return `${hours}小时前`
      if (days < 30) return `${days}天前`
      return date.toLocaleDateString('zh-CN')
    },

    // 上传相关方法
    showUploadDialog() {
      this.uploadForm = {
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      }
      this.musicFileList = []
      this.uploadDialogVisible = true
    },

    handleUploadSingerChange(value) {
      const singer = this.singers.find(s => s.id === value)
      if (singer) {
        this.uploadForm.singerName = singer.name
      }
    },

    beforeCoverUpload(file) {
      const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)
      const isLt5M = file.size / 1024 / 1024 < 5

      if (!isImage) {
        this.$message.error('只能上传 JPG/PNG/GIF/WebP 格式的图片!')
        return false
      }
      if (!isLt5M) {
        this.$message.error('图片大小不能超过 5MB!')
        return false
      }
      return true
    },

    handleCoverSuccess(res, file) {
      if (res.code === 200) {
        this.uploadForm.pic = res.data.url
        this.$message.success('封面图片上传成功')
      } else {
        this.$message.error(res.message || '上传失败')
      }
    },

    beforeMusicUpload(file) {
      const allowedTypes = ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/x-m4a']
      const isAudio = allowedTypes.includes(file.type) ||
        file.name.toLowerCase().match(/\.(mp3|wav|ogg|m4a)$/)
      const isLt50M = file.size / 1024 / 1024 < 50

      if (!isAudio) {
        this.$message.error('只能上传 MP3、WAV、OGG、M4A 格式的音乐文件!')
        return false
      }
      if (!isLt50M) {
        this.$message.error('音乐文件大小不能超过 50MB!')
        return false
      }
      return true
    },

    handleMusicSuccess(res, file) {
      if (res.code === 200) {
        this.uploadForm.url = res.data.url
        this.$message.success('音乐文件上传成功')
        // 自动填充歌曲名称（如果没有填写）
        if (!this.uploadForm.name && res.data.originalName) {
          this.uploadForm.name = res.data.originalName.replace(/\.(mp3|wav|ogg|m4a)$/i, '')
        }
      } else {
        this.$message.error(res.message || '上传失败')
      }
    },

    submitUpload() {
      this.$refs.uploadForm.validate(valid => {
        if (valid) {
          if (!this.uploadForm.url) {
            this.$message.error('请先上传音乐文件')
            return
          }

          this.uploading = true

          axios.post('/api/song', this.uploadForm).then(res => {
            this.uploading = false
            if (res.data.code === 200) {
              this.$message.success('歌曲上传成功')
              this.uploadDialogVisible = false
              this.loadAllSongs()
            } else {
              this.$message.error(res.data.message || '上传失败')
            }
          }).catch(err => {
            this.uploading = false
            this.$message.error('上传失败')
            console.error(err)
          })
        }
      })
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

/* 评论样式 */
.songlist-card {
  height: 200px;
  margin-bottom: 20px;
}

.comment-card {
  height: calc(100vh - 420px);
}

.comment-section {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.comment-input {
  margin-bottom: 15px;
}

.comment-list {
  flex: 1;
  overflow-y: auto;
}

.comment-item {
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-avatar img {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  margin-right: 12px;
}

.comment-content {
  flex: 1;
}

.comment-user {
  font-size: 13px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.comment-text {
  font-size: 13px;
  color: #666;
  line-height: 1.5;
  margin-bottom: 6px;
}

.comment-meta {
  display: flex;
  align-items: center;
  gap: 15px;
  font-size: 12px;
  color: #999;
}

.no-comment {
  text-align: center;
  color: #999;
  padding: 30px 0;
  font-size: 13px;
}

/* 上传相关样式 */
.cover-uploader {
  display: inline-block;
}

.cover-uploader >>> .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.cover-uploader >>> .el-upload:hover {
  border-color: #409EFF;
}

.cover-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 100px;
  height: 100px;
  line-height: 100px;
  text-align: center;
  display: block;
}

.cover-preview {
  width: 100px;
  height: 100px;
  display: block;
  object-fit: cover;
}

.music-uploaded {
  margin-top: 10px;
  color: #67C23A;
  font-size: 13px;
}

.music-uploaded i {
  margin-right: 5px;
}
</style>
