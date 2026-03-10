<template>
  <div class="comment-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>评论管理</span>
      </div>

      <!-- 搜索区域 -->
      <div class="search-area">
        <el-select v-model="searchForm.type" placeholder="选择评论类型" style="width: 200px; margin-right: 10px;" @change="searchComment">
          <el-option label="全部" :value="null"></el-option>
          <el-option label="歌曲评论" :value="0"></el-option>
          <el-option label="歌单评论" :value="1"></el-option>
        </el-select>
        <el-button type="primary" icon="el-icon-search" @click="searchComment">搜索</el-button>
      </div>

      <!-- 评论表格 -->
      <el-table
        :data="commentList"
        border
        stripe
        style="width: 100%; margin-top: 20px;">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column label="用户" width="180">
          <template slot-scope="scope">
            <div style="display: flex; align-items: center;">
              <img :src="scope.row.avatar || defaultPic" style="width: 40px; height: 40px; border-radius: 50%; margin-right: 10px;">
              <span>{{ scope.row.username }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="评论内容" show-overflow-tooltip></el-table-column>
        <el-table-column prop="type" label="类型" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.type === 0 ? 'primary' : 'success'">
              {{ scope.row.type === 0 ? '歌曲评论' : '歌单评论' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="up" label="点赞数" width="100"></el-table-column>
        <el-table-column prop="createTime" label="评论时间" width="180"></el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button size="mini" @click="likeComment(scope.row)">点赞</el-button>
            <el-button size="mini" type="danger" @click="deleteComment(scope.row)">删除</el-button>
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
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'CommentManagement',
  data() {
    return {
      commentList: [],
      searchForm: {
        type: null
      },
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadCommentList()
  },
  methods: {
    loadCommentList() {
      axios.get('/api/comment/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          type: this.searchForm.type
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.commentList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载评论列表失败')
        console.error(err)
      })
    },

    searchComment() {
      this.pagination.current = 1
      this.loadCommentList()
    },

    likeComment(comment) {
      axios.post(`/api/comment/up/${comment.id}`).then(res => {
        if (res.data.code === 200) {
          this.$message.success('点赞成功')
          this.loadCommentList()
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('点赞失败')
        console.error(err)
      })
    },

    deleteComment(comment) {
      this.$confirm('确定要删除该评论吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/comment/${comment.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadCommentList()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('删除失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadCommentList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadCommentList()
    }
  }
}
</script>

<style scoped>
.comment-management {
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
</style>