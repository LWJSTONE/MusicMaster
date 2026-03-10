<template>
  <div class="songlist-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>歌单管理</span>
        <el-button type="primary" size="small" @click="showAddDialog">添加歌单</el-button>
      </div>

      <!-- 搜索区域 -->
      <div class="search-area">
        <el-input
          v-model="searchForm.title"
          placeholder="搜索歌单标题"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="loadSongListList"
          @keyup.enter.native="searchSongList">
        </el-input>
        <el-button type="primary" icon="el-icon-search" @click="searchSongList">搜索</el-button>
      </div>

      <!-- 歌单表格 -->
      <el-table
        :data="songlistList"
        border
        stripe
        style="width: 100%; margin-top: 20px;">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column label="封面" width="100">
          <template slot-scope="scope">
            <img :src="scope.row.pic || defaultPic" style="width: 60px; height: 60px; border-radius: 4px;">
          </template>
        </el-table-column>
        <el-table-column prop="title" label="歌单标题" width="200"></el-table-column>
        <el-table-column prop="introduction" label="简介" show-overflow-tooltip></el-table-column>
        <el-table-column prop="style" label="风格" width="100"></el-table-column>
        <el-table-column prop="creatorName" label="创建者" width="120"></el-table-column>
        <el-table-column prop="songCount" label="歌曲数" width="80"></el-table-column>
        <el-table-column prop="collectCount" label="收藏数" width="80"></el-table-column>
        <el-table-column prop="playCount" label="播放量" width="100"></el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="150">
          <template slot-scope="scope">
            <el-button size="mini" @click="editSongList(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" @click="deleteSongList(scope.row)">删除</el-button>
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

    <!-- 添加/编辑歌单对话框 -->
    <el-dialog :title="dialogTitle" :visible.sync="showDialog" width="600px">
      <el-form :model="songlistForm" :rules="rules" ref="songlistForm" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="songlistForm.title"></el-input>
        </el-form-item>
        <el-form-item label="简介">
          <el-input
            type="textarea"
            v-model="songlistForm.introduction"
            :rows="3"
            placeholder="请输入简介">
          </el-input>
        </el-form-item>
        <el-form-item label="风格">
          <el-input v-model="songlistForm.style"></el-input>
        </el-form-item>
        <el-form-item label="创建者">
          <el-input v-model="songlistForm.creatorName" disabled></el-input>
        </el-form-item>
        <el-form-item label="封面">
          <el-upload
            class="avatar-uploader"
            action="/api/song-list/pic"
            :show-file-list="false"
            :data="{ songListId: songlistForm.id }"
            :on-success="handlePicSuccess">
            <img v-if="songlistForm.pic" :src="songlistForm.pic" class="avatar">
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSongList">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'SongListManagement',
  data() {
    return {
      songlistList: [],
      searchForm: {
        title: ''
      },
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      showDialog: false,
      isEdit: false,
      dialogTitle: '添加歌单',
      songlistForm: {
        id: null,
        title: '',
        introduction: '',
        style: '',
        creatorId: null,
        creatorName: '',
        pic: ''
      },
      rules: {
        title: [
          { required: true, message: '请输入歌单标题', trigger: 'blur' }
        ]
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadSongListList()
  },
  methods: {
    loadSongListList() {
      axios.get('/api/song-list/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          title: this.searchForm.title || undefined
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.songlistList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌单列表失败')
        console.error(err)
      })
    },

    searchSongList() {
      this.pagination.current = 1
      this.loadSongListList()
    },

    showAddDialog() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.isEdit = false
      this.dialogTitle = '添加歌单'
      this.songlistForm = {
        id: null,
        title: '',
        introduction: '',
        style: '',
        creatorId: user.id,
        creatorName: user.username,
        pic: ''
      }
      this.showDialog = true
    },

    editSongList(songlist) {
      this.isEdit = true
      this.dialogTitle = '编辑歌单'
      this.songlistForm = { ...songlist }
      this.showDialog = true
    },

    saveSongList() {
      this.$refs.songlistForm.validate(valid => {
        if (valid) {
          const method = this.isEdit ? 'put' : 'post'
          axios({
            method: method,
            url: '/api/song-list',
            data: this.songlistForm
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success(this.isEdit ? '更新成功' : '添加成功')
              this.showDialog = false
              this.loadSongListList()
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

    deleteSongList(songlist) {
      this.$confirm('确定要删除该歌单吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/song-list/${songlist.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadSongListList()
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
        this.songlistForm.pic = res.data
        this.$message.success('图片上传成功')
      }
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadSongListList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadSongListList()
    }
  }
}
</script>

<style scoped>
.songlist-management {
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