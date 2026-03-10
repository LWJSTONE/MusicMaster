<template>
  <div class="collect-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>我的收藏</span>
      </div>

      <!-- 收藏列表 -->
      <div class="songlist-list">
        <div v-for="collect in collectList" :key="collect.id" class="songlist-item">
          <img :src="collect.songList.pic || defaultPic" class="songlist-pic">
          <div class="songlist-info">
            <div class="songlist-name">{{ collect.songList.title }}</div>
            <div class="songlist-meta">{{ collect.songList.songCount }} 首歌 · {{ collect.songList.collectCount }} 收藏</div>
            <div class="songlist-time">收藏时间: {{ formatDate(collect.createTime) }}</div>
          </div>
          <el-button size="small" type="danger" @click="cancelCollect(collect)">取消收藏</el-button>
        </div>
      </div>

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
  name: 'CollectManagement',
  data() {
    return {
      collectList: [],
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadCollectList()
  },
  methods: {
    loadCollectList() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      axios.get('/api/collect/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          userId: user.id
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.collectList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载收藏列表失败')
        console.error(err)
      })
    },

    cancelCollect(collect) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.$confirm('确定要取消收藏吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete('/api/collect', {
          params: {
            userId: user.id,
            songListId: collect.songListId
          }
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('取消收藏成功')
            this.loadCollectList()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('取消收藏失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    handleSizeChange(val) {
      this.pagination.size = val
      this.loadCollectList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadCollectList()
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
.collect-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.songlist-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.songlist-item {
  display: flex;
  flex-direction: column;
  padding: 20px;
  border-radius: 8px;
  background-color: #fff;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
}

.songlist-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.songlist-pic {
  width: 100%;
  height: 200px;
  border-radius: 8px;
  object-fit: cover;
  margin-bottom: 15px;
}

.songlist-info {
  flex: 1;
}

.songlist-name {
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  font-size: 16px;
}

.songlist-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 5px;
}

.songlist-time {
  font-size: 12px;
  color: #ccc;
}
</style>