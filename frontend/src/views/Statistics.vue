<template>
  <div class="statistics">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :span="4" v-for="(item, index) in statisticsCards" :key="index">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" :style="{ backgroundColor: item.color }">
              <i :class="item.icon"></i>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ item.value }}</div>
              <div class="stat-label">{{ item.label }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 歌曲风格分布 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>歌曲风格分布</span>
          </div>
          <div class="chart-container">
            <div class="pie-legend">
              <div v-for="(item, index) in songStyles" :key="index" class="legend-item">
                <span class="legend-color" :style="{ backgroundColor: item.color }"></span>
                <span>{{ item.name }}: {{ item.value }} 首 ({{ item.percentage }}%)</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 最受欢迎歌曲 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>最受欢迎歌曲 TOP 10</span>
          </div>
          <el-table :data="topSongs" stripe max-height="300">
            <el-table-column type="index" label="排名" width="60"></el-table-column>
            <el-table-column prop="name" label="歌曲名称"></el-table-column>
            <el-table-column prop="singer_name" label="歌手" width="100"></el-table-column>
            <el-table-column prop="play_count" label="播放量" width="100">
              <template slot-scope="scope">
                {{ formatCount(scope.row.play_count) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 最受欢迎歌手 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>最受欢迎歌手 TOP 10</span>
          </div>
          <el-table :data="topSingers" stripe max-height="300">
            <el-table-column type="index" label="排名" width="60"></el-table-column>
            <el-table-column prop="name" label="歌手名称"></el-table-column>
            <el-table-column prop="songCount" label="歌曲数" width="80"></el-table-column>
            <el-table-column prop="playCount" label="总播放量" width="100">
              <template slot-scope="scope">
                {{ formatCount(scope.row.playCount) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 最受欢迎歌单 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>最受欢迎歌单 TOP 10</span>
          </div>
          <el-table :data="topSongLists" stripe max-height="300">
            <el-table-column type="index" label="排名" width="60"></el-table-column>
            <el-table-column prop="title" label="歌单名称"></el-table-column>
            <el-table-column prop="creator_name" label="创建者" width="100"></el-table-column>
            <el-table-column prop="play_count" label="播放量" width="100">
              <template slot-scope="scope">
                {{ formatCount(scope.row.play_count) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 活跃用户排行 -->
      <el-col :span="24">
        <el-card>
          <div slot="header" class="card-header">
            <span>活跃用户排行 TOP 10</span>
          </div>
          <el-table :data="activeUsers" stripe>
            <el-table-column type="index" label="排名" width="80"></el-table-column>
            <el-table-column label="用户" width="200">
              <template slot-scope="scope">
                <div class="user-cell">
                  <img :src="scope.row.avatar || defaultAvatar" class="user-avatar-small">
                  <span>{{ scope.row.nickname || scope.row.username }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="songListCount" label="创建歌单" width="100"></el-table-column>
            <el-table-column prop="uploadCount" label="上传歌曲" width="100"></el-table-column>
            <el-table-column prop="collectCount" label="收藏数" width="100"></el-table-column>
            <el-table-column prop="commentCount" label="评论数" width="100"></el-table-column>
            <el-table-column label="活跃度" width="150">
              <template slot-scope="scope">
                <el-progress 
                  :percentage="getActivityPercentage(scope.row)" 
                  :color="getActivityColor(scope.row)"
                  :show-text="false">
                </el-progress>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 最近上传 -->
      <el-col :span="24">
        <el-card>
          <div slot="header" class="card-header">
            <span>最近上传的歌曲</span>
          </div>
          <el-table :data="recentUploads" stripe>
            <el-table-column prop="name" label="歌曲名称"></el-table-column>
            <el-table-column prop="singer_name" label="歌手" width="120"></el-table-column>
            <el-table-column prop="uploader_name" label="上传者" width="120"></el-table-column>
            <el-table-column prop="create_time" label="上传时间" width="180">
              <template slot-scope="scope">
                {{ formatDate(scope.row.create_time) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Statistics',
  data() {
    return {
      statisticsCards: [
        { label: '总用户数', value: 0, icon: 'el-icon-user', color: '#409EFF' },
        { label: '总歌手数', value: 0, icon: 'el-icon-microphone', color: '#67C23A' },
        { label: '总歌曲数', value: 0, icon: 'el-icon-headset', color: '#E6A23C' },
        { label: '总歌单数', value: 0, icon: 'el-icon-folder-opened', color: '#F56C6C' },
        { label: '总评论数', value: 0, icon: 'el-icon-chat-dot-round', color: '#00BCD4' },
        { label: '总收藏数', value: 0, icon: 'el-icon-star-off', color: '#9C27B0' }
      ],
      songStyles: [],
      topSongs: [],
      topSingers: [],
      topSongLists: [],
      activeUsers: [],
      recentUploads: [],
      defaultAvatar: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  created() {
    this.loadAllData()
  },
  methods: {
    loadAllData() {
      this.loadOverview()
      this.loadSongStyles()
      this.loadTopSongs()
      this.loadTopSingers()
      this.loadTopSongLists()
      this.loadActiveUsers()
      this.loadRecentUploads()
    },

    loadOverview() {
      axios.get('/api/statistics/overview').then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.statisticsCards[0].value = data.userCount || 0
          this.statisticsCards[1].value = data.singerCount || 0
          this.statisticsCards[2].value = data.songCount || 0
          this.statisticsCards[3].value = data.songListCount || 0
          this.statisticsCards[4].value = data.commentCount || 0
          this.statisticsCards[5].value = data.collectCount || 0
        }
      }).catch(err => {
        console.error('加载概览数据失败:', err)
      })
    },

    loadSongStyles() {
      axios.get('/api/statistics/song-styles').then(res => {
        if (res.data.code === 200) {
          this.songStyles = res.data.data || []
        }
      }).catch(err => {
        console.error('加载风格数据失败:', err)
      })
    },

    loadTopSongs() {
      axios.get('/api/statistics/top-songs').then(res => {
        if (res.data.code === 200) {
          this.topSongs = res.data.data || []
        }
      }).catch(err => {
        console.error('加载热门歌曲失败:', err)
      })
    },

    loadTopSingers() {
      axios.get('/api/statistics/top-singers').then(res => {
        if (res.data.code === 200) {
          this.topSingers = res.data.data || []
        }
      }).catch(err => {
        console.error('加载热门歌手失败:', err)
      })
    },

    loadTopSongLists() {
      axios.get('/api/statistics/top-songlists').then(res => {
        if (res.data.code === 200) {
          this.topSongLists = res.data.data || []
        }
      }).catch(err => {
        console.error('加载热门歌单失败:', err)
      })
    },

    loadActiveUsers() {
      axios.get('/api/statistics/active-users').then(res => {
        if (res.data.code === 200) {
          this.activeUsers = res.data.data || []
        }
      }).catch(err => {
        console.error('加载活跃用户失败:', err)
      })
    },

    loadRecentUploads() {
      axios.get('/api/statistics/recent-uploads').then(res => {
        if (res.data.code === 200) {
          this.recentUploads = res.data.data || []
        }
      }).catch(err => {
        console.error('加载最近上传失败:', err)
      })
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
      return date.toLocaleString('zh-CN')
    },

    getActivityPercentage(user) {
      const maxActivity = Math.max(...this.activeUsers.map(u => 
        (u.collectCount || 0) + (u.commentCount || 0) + (u.uploadCount || 0) * 5 + (u.songListCount || 0) * 3
      ))
      const activity = (user.collectCount || 0) + (user.commentCount || 0) + 
                      (user.uploadCount || 0) * 5 + (user.songListCount || 0) * 3
      return maxActivity > 0 ? Math.round((activity / maxActivity) * 100) : 0
    },

    getActivityColor(user) {
      const percentage = this.getActivityPercentage(user)
      if (percentage >= 80) return '#67C23A'
      if (percentage >= 50) return '#E6A23C'
      return '#409EFF'
    }
  }
}
</script>

<style scoped>
.statistics {
  padding: 20px;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
}

.stat-icon i {
  font-size: 24px;
  color: white;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 3px;
}

.stat-label {
  font-size: 12px;
  color: #999;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.chart-container {
  padding: 20px 0;
}

.pie-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 13px;
  min-width: 150px;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  margin-right: 8px;
}

.user-cell {
  display: flex;
  align-items: center;
}

.user-avatar-small {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  margin-right: 8px;
  object-fit: cover;
}
</style>
