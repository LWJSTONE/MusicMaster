<template>
  <div class="song-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>歌曲管理</span>
        <el-button type="primary" size="small" @click="showAddDialog">添加歌曲</el-button>
      </div>

      <!-- 搜索区域 -->
      <div class="search-area">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索歌曲名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @keyup.enter.native="searchSong">
        </el-input>
        <el-select v-model="searchForm.singerId" clearable placeholder="选择歌手" style="width: 200px; margin-right: 10px;" @change="searchSong">
          <el-option
            v-for="singer in singers"
            :key="singer.id"
            :label="singer.name"
            :value="singer.id">
          </el-option>
        </el-select>
        <el-button type="primary" icon="el-icon-search" @click="searchSong">搜索</el-button>
      </div>

      <!-- 歌曲表格 -->
      <el-table
        :data="songList"
        border
        stripe
        style="width: 100%; margin-top: 20px;">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column label="封面" width="100">
          <template slot-scope="scope">
            <img :src="scope.row.pic || defaultPic" style="width: 60px; height: 60px; border-radius: 4px;">
          </template>
        </el-table-column>
        <el-table-column prop="name" label="歌曲名称" width="150"></el-table-column>
        <el-table-column prop="singerName" label="歌手" width="120"></el-table-column>
        <el-table-column prop="album" label="专辑" width="150"></el-table-column>
        <el-table-column prop="style" label="风格" width="100"></el-table-column>
        <el-table-column prop="language" label="语言" width="80"></el-table-column>
        <el-table-column prop="duration" label="时长" width="80">
          <template slot-scope="scope">
            {{ formatTime(scope.row.duration) }}
          </template>
        </el-table-column>
        <el-table-column prop="playCount" label="播放量" width="100"></el-table-column>
        <el-table-column prop="commentCount" label="评论数" width="80"></el-table-column>
        <el-table-column prop="collectCount" label="收藏数" width="80"></el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="180">
          <template slot-scope="scope">
            <el-button size="mini" @click="editSong(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" @click="deleteSong(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="pagination.current"
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pagination.size"
        layout="total, sizes, prev, pager, next, jumper"
        :total="pagination.total"
        style="margin-top: 20px; text-align: right;">
      </el-pagination>
    </el-card>

    <!-- 添加/编辑歌曲对话框 -->
    <el-dialog :title="dialogTitle" :visible.sync="showDialog" width="700px">
      <el-form :model="songForm" :rules="rules" ref="songForm" label-width="80px">
        <el-form-item label="歌曲名称" prop="name">
          <el-input v-model="songForm.name"></el-input>
        </el-form-item>
        <el-form-item label="歌手" prop="singerId">
          <el-select v-model="songForm.singerId" placeholder="请选择歌手" @change="handleSingerChange">
            <el-option
              v-for="singer in singers"
              :key="singer.id"
              :label="singer.name"
              :value="singer.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="专辑">
          <el-input v-model="songForm.album"></el-input>
        </el-form-item>
        <el-form-item label="风格">
          <el-input v-model="songForm.style"></el-input>
        </el-form-item>
        <el-form-item label="语言">
          <el-input v-model="songForm.language"></el-input>
        </el-form-item>
        <el-form-item label="封面">
          <el-upload
            class="avatar-uploader"
            action="/api/song/pic"
            :show-file-list="false"
            :data="{ songId: songForm.id }"
            :on-success="handlePicSuccess">
            <img v-if="songForm.pic" :src="songForm.pic" class="avatar">
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
        </el-form-item>
        <el-form-item label="音乐文件">
          <el-upload
            class="music-uploader"
            action="/api/song/url"
            :show-file-list="false"
            :data="{ songId: songForm.id }"
            :on-success="handleUrlSuccess">
            <el-button size="small" type="primary">点击上传</el-button>
            <div slot="tip" class="el-upload__tip">只能上传mp3文件</div>
          </el-upload>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSong">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'SongManagement',
  data() {
    return {
      songList: [],
      singers: [],
      searchForm: {
        name: '',
        singerId: null
      },
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      showDialog: false,
      isEdit: false,
      dialogTitle: '添加歌曲',
      songForm: {
        id: null,
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      },
      rules: {
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
    this.loadData()
  },
  methods: {
    loadData() {
      this.loadSongList()
      this.loadSingerList()
    },

    loadSongList() {
      axios.get('/api/song/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          name: this.searchForm.name || undefined,
          singerId: this.searchForm.singerId || undefined
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.songList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌曲列表失败')
        console.error(err)
      })
    },

    loadSingerList() {
      axios.get('/api/singer/all').then(res => {
        if (res.data.code === 200) {
          this.singers = res.data.data
        }
      }).catch(err => {
        console.error(err)
      })
    },

    searchSong() {
      this.pagination.current = 1
      this.loadSongList()
    },

    showAddDialog() {
      this.isEdit = false
      this.dialogTitle = '添加歌曲'
      this.songForm = {
        id: null,
        name: '',
        singerId: null,
        singerName: '',
        album: '',
        style: '',
        language: '',
        pic: '',
        url: ''
      }
      this.showDialog = true
    },

    editSong(song) {
      this.isEdit = true
      this.dialogTitle = '编辑歌曲'
      this.songForm = { ...song }
      this.showDialog = true
    },

    handleSingerChange(value) {
      const singer = this.singers.find(s => s.id === value)
      if (singer) {
        this.songForm.singerName = singer.name
      }
    },

    saveSong() {
      this.$refs.songForm.validate(valid => {
        if (valid) {
          const method = this.isEdit ? 'put' : 'post'
          axios({
            method: method,
            url: '/api/song',
            data: this.songForm
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success(this.isEdit ? '更新成功' : '添加成功')
              this.showDialog = false
              this.loadSongList()
            } else {
              this.$message.error(res.data.message)
            }
          }).catch(err => {
            this.$message.error(this.isEdit ? '更新失败' : '添加失败')
            console.error(err)
          })
        }
      })
    },

    deleteSong(song) {
      this.$confirm('确定要删除该歌曲吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/song/${song.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadSongList()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('删除失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    handlePicSuccess(res, file) {
      if (res.code === 200) {
        this.songForm.pic = res.data
        this.$message.success('图片上传成功')
      }
    },

    handleUrlSuccess(res, file) {
      if (res.code === 200) {
        this.songForm.url = res.data
        this.$message.success('音乐上传成功')
      }
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadSongList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadSongList()
    },

    formatTime(seconds) {
      if (!seconds) return '00:00'
      const mins = Math.floor(seconds / 60)
      const secs = Math.floor(seconds % 60)
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }
  }
}
</script>

<style scoped>
.song-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.search-area {
  display: flex;
  align-items: center;
}

.avatar-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.avatar-uploader:hover {
  border-color: #409EFF;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 148px;
  height: 148px;
  line-height: 148px;
  text-align: center;
}

.avatar {
  width: 148px;
  height: 148px;
  display: block;
}
</style>