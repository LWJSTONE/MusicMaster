<template>
  <div class="my-songlists">
    <el-card>
      <div slot="header" class="card-header">
        <span>我的歌单</span>
        <el-button type="primary" size="small" @click="showCreateDialog">
          <i class="el-icon-plus"></i> 创建歌单
        </el-button>
      </div>

      <!-- 歌单列表 -->
      <div class="songlist-grid">
        <div v-for="songlist in songLists" :key="songlist.id" class="songlist-card">
          <img :src="songlist.pic || defaultPic" class="songlist-cover" @click="viewSongList(songlist)">
          <div class="songlist-info">
            <div class="songlist-title" @click="viewSongList(songlist)">{{ songlist.title }}</div>
            <div class="songlist-meta">
              <span>{{ songlist.songCount || 0 }} 首歌曲</span>
              <span>{{ songlist.playCount || 0 }} 次播放</span>
            </div>
            <div class="songlist-intro" v-if="songlist.introduction">{{ songlist.introduction }}</div>
            <div class="songlist-time">创建于 {{ formatDate(songlist.createTime) }}</div>
          </div>
          <div class="songlist-actions">
            <el-button size="mini" type="primary" @click="editSongList(songlist)">编辑</el-button>
            <el-button size="mini" type="info" @click="manageSongs(songlist)">管理歌曲</el-button>
            <el-button size="mini" type="danger" @click="deleteSongList(songlist)">删除</el-button>
          </div>
        </div>
        <div v-if="songLists.length === 0" class="empty-tip">
          <i class="el-icon-folder-opened"></i>
          <p>暂无歌单，点击上方按钮创建您的第一个歌单</p>
        </div>
      </div>
    </el-card>

    <!-- 创建/编辑歌单对话框 -->
    <el-dialog :title="isEdit ? '编辑歌单' : '创建歌单'" :visible.sync="dialogVisible" width="500px">
      <el-form :model="songlistForm" :rules="rules" ref="songlistForm" label-width="80px">
        <el-form-item label="歌单名称" prop="title">
          <el-input v-model="songlistForm.title" placeholder="请输入歌单名称"></el-input>
        </el-form-item>
        <el-form-item label="风格">
          <el-input v-model="songlistForm.style" placeholder="如：流行、摇滚、民谣"></el-input>
        </el-form-item>
        <el-form-item label="简介">
          <el-input type="textarea" v-model="songlistForm.introduction" :rows="3" placeholder="请输入歌单简介"></el-input>
        </el-form-item>
        <el-form-item label="封面">
          <el-upload
            class="cover-uploader"
            action="/api/song-list/pic"
            :show-file-list="false"
            :on-success="handleCoverSuccess"
            :before-upload="beforeCoverUpload">
            <img v-if="songlistForm.pic" :src="songlistForm.pic" class="cover-preview">
            <i v-else class="el-icon-plus cover-uploader-icon"></i>
          </el-upload>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </span>
    </el-dialog>

    <!-- 管理歌曲对话框 -->
    <el-dialog title="管理歌单歌曲" :visible.sync="songsDialogVisible" width="800px">
      <div class="manage-songs">
        <div class="add-song-section">
          <el-select v-model="selectedSongId" placeholder="选择要添加的歌曲" filterable style="width: 400px;">
            <el-option
              v-for="song in allSongs"
              :key="song.id"
              :label="`${song.name} - ${song.singerName || '未知'}`"
              :value="song.id">
            </el-option>
          </el-select>
          <el-button type="primary" @click="addSongToSongList" :disabled="!selectedSongId">添加歌曲</el-button>
        </div>

        <el-table :data="songListSongs" style="width: 100%; margin-top: 20px;">
          <el-table-column prop="name" label="歌曲名称"></el-table-column>
          <el-table-column prop="singerName" label="歌手" width="120"></el-table-column>
          <el-table-column prop="album" label="专辑" width="150"></el-table-column>
          <el-table-column label="操作" width="100">
            <template slot-scope="scope">
              <el-button type="text" size="small" @click="removeSongFromSongList(scope.row)">移除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'MySongLists',
  data() {
    return {
      songLists: [],
      allSongs: [],
      songListSongs: [],
      dialogVisible: false,
      songsDialogVisible: false,
      isEdit: false,
      currentSongListId: null,
      selectedSongId: null,
      songlistForm: {
        title: '',
        style: '',
        introduction: '',
        pic: ''
      },
      rules: {
        title: [
          { required: true, message: '请输入歌单名称', trigger: 'blur' }
        ]
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadSongLists()
    this.loadAllSongs()
  },
  methods: {
    loadSongLists() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      axios.get(`/api/song-list/user/${user.id}`).then(res => {
        if (res.data.code === 200) {
          this.songLists = res.data.data || []
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌单失败')
        console.error(err)
      })
    },

    loadAllSongs() {
      axios.get('/api/song/all').then(res => {
        if (res.data.code === 200) {
          this.allSongs = res.data.data || []
        }
      }).catch(err => {
        console.error(err)
      })
    },

    showCreateDialog() {
      this.isEdit = false
      this.songlistForm = {
        title: '',
        style: '',
        introduction: '',
        pic: ''
      }
      this.currentSongListId = null
      this.dialogVisible = true
    },

    editSongList(songlist) {
      this.isEdit = true
      this.currentSongListId = songlist.id
      this.songlistForm = {
        title: songlist.title,
        style: songlist.style,
        introduction: songlist.introduction,
        pic: songlist.pic
      }
      this.dialogVisible = true
    },

    submitForm() {
      this.$refs.songlistForm.validate(valid => {
        if (valid) {
          const user = JSON.parse(localStorage.getItem('user') || '{}')
          
          if (this.isEdit) {
            // 编辑歌单
            axios.put('/api/song-list/user/' + this.currentSongListId, this.songlistForm, {
              params: { userId: user.id }
            }).then(res => {
              if (res.data.code === 200) {
                this.$message.success('更新成功')
                this.dialogVisible = false
                this.loadSongLists()
              } else {
                this.$message.error(res.data.message)
              }
            }).catch(err => {
              this.$message.error('更新失败')
              console.error(err)
            })
          } else {
            // 创建歌单
            const data = {
              ...this.songlistForm,
              creatorId: user.id,
              creatorName: user.nickname || user.username
            }
            axios.post('/api/song-list/create', data).then(res => {
              if (res.data.code === 200) {
                this.$message.success('创建成功')
                this.dialogVisible = false
                this.loadSongLists()
              } else {
                this.$message.error(res.data.message)
              }
            }).catch(err => {
              this.$message.error('创建失败')
              console.error(err)
            })
          }
        }
      })
    },

    deleteSongList(songlist) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.$confirm('确定要删除该歌单吗？删除后无法恢复', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete('/api/song-list/user/' + songlist.id, {
          params: { userId: user.id }
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadSongLists()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('删除失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    manageSongs(songlist) {
      this.currentSongListId = songlist.id
      this.loadSongListSongs(songlist.id)
      this.songsDialogVisible = true
    },

    loadSongListSongs(songListId) {
      axios.get(`/api/song-list/${songListId}/songs`).then(res => {
        if (res.data.code === 200) {
          this.songListSongs = res.data.data || []
        }
      }).catch(err => {
        console.error(err)
        this.songListSongs = []
      })
    },

    addSongToSongList() {
      if (!this.selectedSongId || !this.currentSongListId) return

      axios.post(`/api/song-list/${this.currentSongListId}/songs/${this.selectedSongId}`).then(res => {
        if (res.data.code === 200) {
          this.$message.success('添加成功')
          this.selectedSongId = null
          this.loadSongListSongs(this.currentSongListId)
          this.loadSongLists()
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('添加失败')
        console.error(err)
      })
    },

    removeSongFromSongList(song) {
      axios.delete(`/api/song-list/${this.currentSongListId}/songs/${song.id}`).then(res => {
        if (res.data.code === 200) {
          this.$message.success('移除成功')
          this.loadSongListSongs(this.currentSongListId)
          this.loadSongLists()
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('移除失败')
        console.error(err)
      })
    },

    viewSongList(songlist) {
      // 可以跳转到歌单详情或播放歌单
      this.$message.info(`查看歌单: ${songlist.title}`)
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
        this.songlistForm.pic = res.data.url
        this.$message.success('封面上传成功')
      } else {
        this.$message.error(res.message || '上传失败')
      }
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
.my-songlists {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.songlist-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.songlist-card {
  display: flex;
  flex-direction: column;
  padding: 15px;
  border-radius: 8px;
  background-color: #fff;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
}

.songlist-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.songlist-cover {
  width: 100%;
  height: 180px;
  border-radius: 8px;
  object-fit: cover;
  cursor: pointer;
}

.songlist-info {
  flex: 1;
  margin-top: 15px;
}

.songlist-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  cursor: pointer;
  margin-bottom: 8px;
}

.songlist-title:hover {
  color: #409EFF;
}

.songlist-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 5px;
}

.songlist-meta span {
  margin-right: 15px;
}

.songlist-intro {
  font-size: 13px;
  color: #666;
  margin: 8px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.songlist-time {
  font-size: 12px;
  color: #ccc;
}

.songlist-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.songlist-actions .el-button {
  flex: 1;
}

.empty-tip {
  grid-column: 1 / -1;
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
  width: 120px;
  height: 120px;
  line-height: 120px;
  text-align: center;
  display: block;
}

.cover-preview {
  width: 120px;
  height: 120px;
  display: block;
  object-fit: cover;
}

/* 管理歌曲样式 */
.manage-songs {
  min-height: 300px;
}

.add-song-section {
  display: flex;
  gap: 15px;
  align-items: center;
}
</style>
