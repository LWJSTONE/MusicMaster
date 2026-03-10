<template>
  <div class="singer-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>歌手管理</span>
        <el-button type="primary" size="small" @click="showAddDialog">添加歌手</el-button>
      </div>

      <!-- 搜索区域 -->
      <div class="search-area">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索歌手名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="loadSingerList"
          @keyup.enter.native="searchSinger">
        </el-input>
        <el-button type="primary" icon="el-icon-search" @click="searchSinger">搜索</el-button>
      </div>

      <!-- 歌手表格 -->
      <el-table
        :data="singerList"
        border
        stripe
        style="width: 100%; margin-top: 20px;">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column label="头像" width="100">
          <template slot-scope="scope">
            <img :src="scope.row.pic || defaultPic" style="width: 60px; height: 60px; border-radius: 4px;">
          </template>
        </el-table-column>
        <el-table-column prop="name" label="姓名" width="150"></el-table-column>
        <el-table-column prop="sex" label="性别" width="80">
          <template slot-scope="scope">
            <el-tag :type="scope.row.sex === 1 ? 'primary' : 'danger'">
              {{ scope.row.sex === 1 ? '男' : (scope.row.sex === 2 ? '组合' : '女') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="birth" label="出生日期" width="120"></el-table-column>
        <el-table-column prop="location" label="地区" width="120"></el-table-column>
        <el-table-column prop="introduction" label="简介" show-overflow-tooltip></el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="150">
          <template slot-scope="scope">
            <el-button size="mini" @click="editSinger(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" @click="deleteSinger(scope.row)">删除</el-button>
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

    <!-- 添加/编辑歌手对话框 -->
    <el-dialog :title="dialogTitle" :visible.sync="showDialog" width="600px">
      <el-form :model="singerForm" :rules="rules" ref="singerForm" label-width="80px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="singerForm.name"></el-input>
        </el-form-item>
        <el-form-item label="性别" prop="sex">
          <el-select v-model="singerForm.sex" placeholder="请选择性别">
            <el-option label="女" :value="0"></el-option>
            <el-option label="男" :value="1"></el-option>
            <el-option label="组合" :value="2"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="出生日期">
          <el-date-picker
            v-model="singerForm.birth"
            type="date"
            placeholder="选择出生日期"
            value-format="yyyy-MM-dd">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="地区">
          <el-input v-model="singerForm.location"></el-input>
        </el-form-item>
        <el-form-item label="简介">
          <el-input
            type="textarea"
            v-model="singerForm.introduction"
            :rows="3"
            placeholder="请输入简介">
          </el-input>
        </el-form-item>
        <el-form-item label="头像">
          <el-upload
            class="avatar-uploader"
            action="/api/singer/pic"
            :show-file-list="false"
            :data="{ singerId: singerForm.id }"
            :on-success="handlePicSuccess">
            <img v-if="singerForm.pic" :src="singerForm.pic" class="avatar">
            <i v-else class="el-icon-plus avatar-uploader-icon"></i>
          </el-upload>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSinger">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'SingerManagement',
  data() {
    return {
      singerList: [],
      searchForm: {
        name: ''
      },
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      showDialog: false,
      isEdit: false,
      dialogTitle: '添加歌手',
      singerForm: {
        id: null,
        name: '',
        sex: 1,
        birth: '',
        location: '',
        introduction: '',
        pic: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入歌手姓名', trigger: 'blur' }
        ],
        sex: [
          { required: true, message: '请选择性别', trigger: 'change' }
        ]
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadSingerList()
  },
  methods: {
    loadSingerList() {
      axios.get('/api/singer/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          name: this.searchForm.name || undefined
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.singerList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌手列表失败')
        console.error(err)
      })
    },

    searchSinger() {
      this.pagination.current = 1
      this.loadSingerList()
    },

    showAddDialog() {
      this.isEdit = false
      this.dialogTitle = '添加歌手'
      this.singerForm = {
        id: null,
        name: '',
        sex: 1,
        birth: '',
        location: '',
        introduction: '',
        pic: ''
      }
      this.showDialog = true
    },

    editSinger(singer) {
      this.isEdit = true
      this.dialogTitle = '编辑歌手'
      this.singerForm = { ...singer }
      this.showDialog = true
    },

    saveSinger() {
      this.$refs.singerForm.validate(valid => {
        if (valid) {
          const method = this.isEdit ? 'put' : 'post'
          axios({
            method: method,
            url: '/api/singer',
            data: this.singerForm
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success(this.isEdit ? '更新成功' : '添加成功')
              this.showDialog = false
              this.loadSingerList()
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

    deleteSinger(singer) {
      this.$confirm('确定要删除该歌手吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/singer/${singer.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadSingerList()
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
        this.singerForm.pic = res.data
        this.$message.success('图片上传成功')
      }
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadSingerList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadSingerList()
    }
  }
}
</script>

<style scoped>
.singer-management {
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