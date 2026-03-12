<template>
  <div class="my-comments">
    <el-card>
      <div slot="header" class="card-header">
        <span>我的评论</span>
      </div>

      <!-- 评论列表 -->
      <div class="comment-list" v-if="commentList.length > 0">
        <div v-for="comment in commentList" :key="comment.id" class="comment-item">
          <div class="comment-info">
            <div class="comment-type">
              <el-tag :type="comment.type === 0 ? 'primary' : 'success'" size="small">
                {{ comment.type === 0 ? '歌曲评论' : '歌单评论' }}
              </el-tag>
            </div>
            <div class="comment-content">{{ comment.content }}</div>
            <div class="comment-meta">
              <span class="comment-time">{{ formatDate(comment.createTime) }}</span>
              <span class="comment-likes">
                <i class="el-icon-thumb"></i> {{ comment.up || 0 }} 人点赞
              </span>
            </div>
          </div>
          <div class="comment-actions">
            <el-button type="danger" size="mini" @click="deleteComment(comment)">删除</el-button>
          </div>
        </div>
      </div>

      <!-- 无评论提示 -->
      <div v-else class="no-comments">
        <i class="el-icon-chat-dot-round"></i>
        <p>暂无评论记录</p>
        <p class="tip">去音乐播放页面给您喜欢的歌曲评论吧~</p>
      </div>

      <!-- 分页 -->
      <el-pagination
        v-if="commentList.length > 0"
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
  name: 'MyComments',
  data() {
    return {
      commentList: [],
      pagination: {
        current: 1,
        size: 10,
        total: 0
      }
    }
  },
  created() {
    this.loadComments()
  },
  methods: {
    loadComments() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      axios.get('/api/comment/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          userId: user.id
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          // 过滤出当前用户的评论
          this.commentList = (data.records || []).filter(c => c.userId === user.id)
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message || '加载评论失败')
        }
      }).catch(err => {
        this.$message.error('加载评论失败')
        console.error(err)
      })
    },

    deleteComment(comment) {
      this.$confirm('确定要删除这条评论吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/comment/${comment.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadComments()
          } else {
            this.$message.error(res.data.message || '删除失败')
          }
        }).catch(err => {
          this.$message.error('删除失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadComments()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadComments()
    },

    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleString('zh-CN')
    }
  }
}
</script>

<style scoped>
.my-comments {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.comment-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 20px;
  border-radius: 8px;
  background-color: #fafafa;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
}

.comment-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.comment-info {
  flex: 1;
}

.comment-type {
  margin-bottom: 10px;
}

.comment-content {
  font-size: 14px;
  color: #333;
  line-height: 1.6;
  margin-bottom: 10px;
}

.comment-meta {
  display: flex;
  gap: 20px;
  font-size: 12px;
  color: #999;
}

.comment-likes {
  color: #1890ff;
}

.comment-actions {
  margin-left: 20px;
}

.no-comments {
  text-align: center;
  padding: 60px 20px;
  color: #999;
}

.no-comments i {
  font-size: 60px;
  margin-bottom: 20px;
  color: #d9d9d9;
}

.no-comments p {
  margin: 0;
  font-size: 16px;
}

.no-comments .tip {
  font-size: 13px;
  margin-top: 10px;
  color: #bbb;
}
</style>
