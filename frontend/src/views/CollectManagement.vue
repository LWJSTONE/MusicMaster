<template>
  <div class="collect-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>我的收藏</span>
      </div>

      <!-- Tab切换 -->
      <el-tabs v-model="activeTab" @tab-click="handleTabChange">
        <el-tab-pane label="歌曲收藏" name="songs">
          <div class="song-list" v-if="songCollectList.length > 0">
            <div v-for="collect in songCollectList" :key="collect.id" class="song-item">
              <img :src="getSongPic(collect.songId)" class="song-pic">
              <div class="song-info">
                <div class="song-name">{{ getSongName(collect.songId) }}</div>
                <div class="song-meta">{{ getSongSinger(collect.songId) }} · {{ getSongAlbum(collect.songId) }}</div>
                <div class="song-time">收藏时间: {{ formatDate(collect.createTime) }}</div>
              </div>
              <el-button size="small" type="danger" @click="cancelSongCollect(collect)">取消收藏</el-button>
            </div>
          </div>
          <el-empty v-else description="暂无收藏的歌曲"></el-empty>
          
          <!-- 分页 -->
          <el-pagination
            @size-change="handleSongSizeChange"
            @current-change="handleSongCurrentChange"
            :current-page="songPagination.current"
            :page-sizes="[10, 20, 50, 100]"
            :page-size="songPagination.size"
            layout="total, sizes, prev, pager, next, jumper"
            :total="songPagination.total"
            style="margin-top: 20px; text-align: right;"
            v-if="songCollectList.length > 0">
          </el-pagination>
        </el-tab-pane>
        
        <el-tab-pane label="歌单收藏" name="songlists">
          <div class="songlist-list" v-if="collectList.length > 0">
            <div v-for="collect in collectList" :key="collect.id" class="songlist-item">
              <img :src="collect.songList && collect.songList.pic ? collect.songList.pic : defaultPic" class="songlist-pic">
              <div class="songlist-info">
                <div class="songlist-name">{{ collect.songList ? collect.songList.title : '未知歌单' }}</div>
                <div class="songlist-meta">{{ collect.songList ? collect.songList.songCount : 0 }} 首歌 · {{ collect.songList ? collect.songList.collectCount : 0 }} 收藏</div>
                <div class="songlist-time">收藏时间: {{ formatDate(collect.createTime) }}</div>
              </div>
              <el-button size="small" type="danger" @click="cancelCollect(collect)">取消收藏</el-button>
            </div>
          </div>
          <el-empty v-else description="暂无收藏的歌单"></el-empty>
          
          <!-- 分页 -->
          <el-pagination
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            :current-page="pagination.current"
            :page-sizes="[10, 20, 50, 100]"
            :page-size="pagination.size"
            layout="total, sizes, prev, pager, next, jumper"
            :total="pagination.total"
            style="margin-top: 20px; text-align: right;"
            v-if="collectList.length > 0">
          </el-pagination>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'CollectManagement',
  data() {
    return {
      activeTab: 'songs',
      // 歌单收藏
      collectList: [],
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      // 歌曲收藏
      songCollectList: [],
      songPagination: {
        current: 1,
        size: 10,
        total: 0
      },
      // 歌曲信息缓存
      songMap: {},
      defaultPic: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadSongCollectList()
    this.loadCollectList()
  },
  methods: {
    handleTabChange(tab) {
      if (tab.name === 'songs') {
        this.loadSongCollectList()
      } else {
        this.loadCollectList()
      }
    },

    // 歌曲收藏相关方法
    loadSongCollectList() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) {
        this.$message.error('请先登录')
        return
      }

      axios.get('/api/collect/page', {
        params: {
          current: this.songPagination.current,
          size: this.songPagination.size,
          userId: user.id,
          type: 1
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.songCollectList = data.records
          this.songPagination.total = data.total
          // 加载歌曲详情
          this.loadSongDetails(data.records)
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载歌曲收藏列表失败')
        console.error(err)
      })
    },

    loadSongDetails(collects) {
      const songIds = collects.map(c => c.songId).filter(id => id && !this.songMap[id])
      if (songIds.length === 0) return

      // 批量获取歌曲信息
      axios.get('/api/song/all').then(res => {
        if (res.data.code === 200) {
          res.data.data.forEach(song => {
            this.$set(this.songMap, song.id, song)
          })
        }
      }).catch(err => {
        console.error('加载歌曲详情失败:', err)
      })
    },

    getSongName(songId) {
      const song = this.songMap[songId]
      return song ? song.name : `歌曲 #${songId}`
    },

    getSongSinger(songId) {
      const song = this.songMap[songId]
      return song ? song.singerName : '未知歌手'
    },

    getSongAlbum(songId) {
      const song = this.songMap[songId]
      return song ? (song.album || '未知专辑') : '未知专辑'
    },

    getSongPic(songId) {
      const song = this.songMap[songId]
      return song && song.pic ? song.pic : this.defaultPic
    },

    cancelSongCollect(collect) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.$confirm('确定要取消收藏该歌曲吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete('/api/collect/song', {
          params: {
            userId: user.id,
            songId: collect.songId
          }
        }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('取消收藏成功')
            this.loadSongCollectList()
          } else {
            this.$message.error(res.data.message)
          }
        }).catch(err => {
          this.$message.error('取消收藏失败')
          console.error(err)
        })
      }).catch(() => {})
    },

    handleSongSizeChange(val) {
      this.songPagination.size = val
      this.loadSongCollectList()
    },

    handleSongCurrentChange(val) {
      this.songPagination.current = val
      this.loadSongCollectList()
    },

    // 歌单收藏相关方法
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
          userId: user.id,
          type: 0
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.collectList = data.records
          this.pagination.total = data.total
          // 加载歌单详情
          this.loadSongListDetails(data.records)
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载收藏列表失败')
        console.error(err)
      })
    },

    loadSongListDetails(collects) {
      axios.get('/api/song-list/all').then(res => {
        if (res.data.code === 200) {
          const songListMap = {}
          res.data.data.forEach(sl => {
            songListMap[sl.id] = sl
          })
          this.collectList = collects.map(c => ({
            ...c,
            songList: songListMap[c.songListId] || null
          }))
        }
      }).catch(err => {
        console.error('加载歌单详情失败:', err)
      })
    },

    cancelCollect(collect) {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      this.$confirm('确定要取消收藏该歌单吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete('/api/collect/songlist', {
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

/* 歌曲列表样式 */
.song-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.song-item {
  display: flex;
  align-items: center;
  padding: 15px;
  border-radius: 8px;
  background-color: #fff;
  border: 1px solid #e8e8e8;
  transition: all 0.3s;
}

.song-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.song-pic {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  margin-right: 15px;
}

.song-info {
  flex: 1;
}

.song-name {
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
  font-size: 15px;
}

.song-meta {
  font-size: 12px;
  color: #999;
  margin-bottom: 3px;
}

.song-time {
  font-size: 12px;
  color: #ccc;
}

/* 歌单列表样式 */
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
