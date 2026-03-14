<template>
  <div class="my-songs">
    <el-card>
      <div slot="header" class="card-header">
        <span>我的音乐</span>
        <el-button type="primary" size="small" @click="showUploadDialog">
          <i class="el-icon-upload2"></i> 上传新歌曲
        </el-button>
      </div>

      <!-- 歌曲列表 -->
      <el-table :data="mySongs" style="width: 100%">
        <el-table-column width="80">
          <template slot-scope="scope">
            <img :src="scope.row.pic || defaultPic" class="song-cover">
          </template>
        </el-table-column>
        <el-table-column prop="name" label="歌曲名称" min-width="150"></el-table-column>
        <el-table-column prop="singerName" label="歌手" width="120"></el-table-column>
        <el-table-column prop="album" label="专辑" width="120"></el-table-column>
        <el-table-column prop="style" label="风格" width="80"></el-table-column>
        <el-table-column prop="playCount" label="播放量" width="100">
          <template slot-scope="scope">
            {{ formatCount(scope.row.playCount) }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="上传时间" width="120">
          <template slot-scope="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" @click="editSong(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" @click="deleteSong(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="mySongs.length === 0" class="empty-tip">
        <i class="el-icon-headset"></i>
        <p>暂无上传的歌曲，点击上方按钮上传您的第一首歌曲</p>
      </div>
    </el-card>

    <!-- 上传/编辑歌曲对话框 -->
    <el-dialog :title="isEdit ? '编辑歌曲' : '上传歌曲'" :visible.sync="uploadDialogVisible" width="600px">
      <el-form :model="songForm" :rules="songRules" ref="songForm" label-width="80px">
        <el-form-item label="歌曲名称" prop="name">
          <el-input v-model="songForm.name" placeholder="请输入歌曲名称"></el-input>
        </el-form-item>
        <el-form-item label="歌手" prop="singerId">
          <el-select v-model="songForm.singerId" placeholder="请选择歌手" @change="handleSingerChange" style="width: 100%;">
            <el-option
              v-for="singer in singers"
              :key="singer.id"
              :label="singer.name"
              :value="singer.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="专辑">
          <el-input v-model="songForm.album" placeholder="请输入专辑名称"></el-input>
        </el-form-item>
        <el-form-item label="风格">
          <el-input v-model="songForm.style" placeholder="如：流行、摇滚、民谣"></el-input>
        </el-form-item>
        <el-form-item label="语言">
          <el-input v-model="songForm.language" placeholder="如：国语、英语、日语"></el-input>
        </el-form-item>
        <el-form-item label="封面">
          <el-upload
            class="cover-uploader"
            action="/api/song/pic"
            :show-file-list="false"
            :on-success="handleCoverSuccess"
            :before-upload="beforeCoverUpload">
            <img v-if="songForm.pic" :src="songForm.pic" class="cover-preview">
            <i v-else class="el-icon-plus cover-uploader-icon"></i>
          </el-upload>
        </el-form-item>
        <el-form-item label="音乐文件" v-if="!isEdit">
          <el-upload
            class="music-uploader"
            action="/api/song/upload"
            :show-file-list="false"
            :on-success="handleMusicSuccess"
            :before-upload="beforeMusicUpload">
            <el-button size="small" type="primary">
              <i class="el-icon-upload2"></i> 选择音乐文件
            </el-button>
            <div slot="tip" class="el-upload__tip">支持 MP3、WAV、OGG、M4A 格式，最大 50MB</div>
          </el-upload>
          <div v-if="songForm.url" class="music-uploaded">
            <i class="el-icon-success" style="color: #67C23A;"></i>
            <span>音乐文件已上传</span>
          </div>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitSong" :loading="uploading">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'MySongs',
  data() {
    return {
      mySongs: [],
      singers: [],
      uploadDialogVisible: false,
      isEdit: false,
      uploading: false,
      currentSongId: null,
      songForm: {
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      },
      songRules: {
        name: [
          { required: true, message: '请输入歌曲名称', trigger: 'blur' }
        ],
        singerId: [
          { required: true, message: '请选择歌手', trigger: 'change' }
        ]
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadMySongs()
    this.loadSingers()
  },
  methods: {
    loadMySongs() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      axios.get(`/api/song/user/${user.id}`).then(res => {
        if (res.data.code === 200) {
          this.mySongs = res.data.data || []
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌曲失败')
        console.error(err)
      })
    },

    loadSingers() {
      axios.get('/api/singer/all').then(res => {
        if (res.data.code === 200) {
          this.singers = res.data.data || []
        }
      }).catch(err => {
        console.error(err)
      })
    },

    showUploadDialog() {
      this.isEdit = false
      this.currentSongId = null
      this.songForm = {
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      }
      this.uploadDialogVisible = true
    },

    editSong(song) {
      this.isEdit = true
      this.currentSongId = song.id
      this.songForm = {
        name: song.name,
        singerId: song.singerId,
        singerName: song.singerName,
        album: song.album,
        style: song.style,
        language: song.language,
        pic: song.pic,
        url: song.url
      }
      this.uploadDialogVisible = true
    },

    handleSingerChange(value) {
      const singer = this.singers.find(s => s.id === value)
      if (singer) {
        this.songForm.singerName = singer.name
      }
    },

    submitSong() {
      this.$refs.songForm.validate(valid => {
        if (valid) {
          const user = JSON.parse(localStorage.getItem('user') || '{}')
          
          if (this.isEdit) {
            // 编辑歌曲
            axios.put('/api/song/user/' + this.currentSongId, this.songForm, {
              params: { userId: user.id }
            }).then(res => {
              if (res.data.code === 200) {
                this.$message.success('更新成功')
                this.uploadDialogVisible = false
                this.loadMySongs()
              } else {
                this.$message.error(res.data.message)
              }
            }).catch(err => {
              this.$message.error('更新失败')
              console.error(err)
            })
          } else {
            // 上传新歌曲
            if (!this.songForm.url) {
              this.$message.error('请上传音乐文件')
              return
            }

            this.uploading = true
            const data = {
              ...this.songForm,
              uploaderId: user.id,
              uploaderName: user.nickname || user.username
            }

            axios.post('/api/song/upload-song', data).then(res => {
              this.uploading = false
              if (res.data.code === 200) {
                this.$message.success('上传成功')
                this.uploadDialogVisible = false
                this.loadMySongs()
              } else {
                this.$message.error(res.data.message)
              }
            }).catch(err => {
              this.uploading = false
              this.$message.error('上传失败')
              console.error(err)
            })
          }
        }
      })
    },

    deleteSong(song) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.$confirm('确定要删除该歌曲吗？删除后无法恢复', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete('/api/song/user/' + song.id, {
          params: { userId: user.id }
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadMySongs()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('删除失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    beforeCoverUpload(file) {
      const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)
      const isLt5M = file.size / 1024 / 1024 < 5

      if (!isImage) {
        this.$message.error('只能上传图片文件!')
        return false
      }
      if (!isLt5M) {
        this.$message.error('图片大小不能超过 5MB!')
        return false
      }
      return true
    },

    handleCoverSuccess(res) {
      if (res.code === 200) {
        this.songForm.pic = res.data.url
        this.$message.success('封面上传成功')
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

    handleMusicSuccess(res) {
      if (res.code === 200) {
        this.songForm.url = res.data.url
        this.$message.success('音乐文件上传成功')
        // 自动填充歌曲名称
        if (!this.songForm.name && res.data.originalName) {
          this.songForm.name = res.data.originalName.replace(/\.(mp3|wav|ogg|m4a)$/i, '')
        }
      } else {
        this.$message.error(res.message || '上传失败')
      }
    },

    formatCount(count) {
      if (!count) return '0'
      if (count >= 10000) {
        return (count / 10000).toFixed(1) + '万'
      }
      return count.toString()
    },

    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('zh-CN')
    }
  }
}
</script>

<style scoped>
.my-songs {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.song-cover {
  width: 50px;
  height: 50px;
  border-radius: 4px;
  object-fit: cover;
}

.empty-tip {
  text-align: center;
  padding: 60px 0;
  color: #999;
}

.empty-tip i {
  font-size: 60px;
  margin-bottom: 15px;
}

.empty-tip p {
  font-size: 14px;
}

/* 封面上传样式 */
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
