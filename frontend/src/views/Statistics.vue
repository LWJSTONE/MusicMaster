<template>
  <div class="statistics">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :span="6" v-for="(item, index) in statisticsCards" :key="index">
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
      <!-- 用户增长趋势 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>用户增长趋势</span>
          </div>
          <div class="chart-container">
            <div class="mock-chart">
              <div class="chart-bar" v-for="(value, index) in userTrend" :key="index" :style="{ height: value + '%' }"></div>
            </div>
            <div class="chart-labels">
              <span v-for="(_, index) in userTrend" :key="index">第{{ index + 1 }}月</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 歌曲类型分布 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>歌曲类型分布</span>
          </div>
          <div class="chart-container">
            <div class="pie-chart">
              <div class="pie-segment" v-for="(item, index) in songTypes" :key="index" :style="{ 
                backgroundColor: item.color,
                transform: `rotate(${item.startDeg}deg) ${index > 0 ? '' : ''}`
              }"></div>
            </div>
            <div class="pie-legend">
              <div v-for="(item, index) in songTypes" :key="index" class="legend-item">
                <span class="legend-color" :style="{ backgroundColor: item.color }"></span>
                <span>{{ item.name }}: {{ item.value }}%</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 最受欢迎歌手 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>最受欢迎歌手</span>
          </div>
          <el-table :data="topSingers" stripe>
            <el-table-column type="index" label="排名" width="80"></el-table-column>
            <el-table-column prop="name" label="歌手名称"></el-table-column>
            <el-table-column prop="playCount" label="播放量" width="150"></el-table-column>
            <el-table-column prop="songCount" label="歌曲数" width="100"></el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 最受欢迎歌曲 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>最受欢迎歌曲</span>
          </div>
          <el-table :data="topSongs" stripe>
            <el-table-column type="index" label="排名" width="80"></el-table-column>
            <el-table-column prop="name" label="歌曲名称"></el-table-column>
            <el-table-column prop="singerName" label="歌手" width="120"></el-table-column>
            <el-table-column prop="playCount" label="播放量" width="120"></el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 活跃用户排行 -->
      <el-col :span="24">
        <el-card>
          <div slot="header" class="card-header">
            <span>活跃用户排行</span>
          </div>
          <el-table :data="activeUsers" stripe>
            <el-table-column type="index" label="排名" width="80"></el-table-column>
            <el-table-column prop="username" label="用户名"></el-table-column>
            <el-table-column prop="nickname" label="昵称"></el-table-column>
            <el-table-column prop="collectCount" label="收藏数" width="120"></el-table-column>
            <el-table-column prop="commentCount" label="评论数" width="120"></el-table-column>
            <el-table-column prop="loginCount" label="登录次数" width="120"></el-table-column>
            <el-table-column prop="lastLoginTime" label="最后登录时间" width="180"></el-table-column>
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
        { label: '总用户数', value: 1250, icon: 'el-icon-user', color: '#409EFF' },
        { label: '总歌手数', value: 156, icon: 'el-icon-microphone', color: '#67C23A' },
        { label: '总歌曲数', value: 3280, icon: 'el-icon-headset', color: '#E6A23C' },
        { label: '总歌单数', value: 485, icon: 'el-icon-folder-opened', color: '#F56C6C' }
      ],
      userTrend: [20, 35, 45, 60, 75, 85, 90, 95, 100, 85, 90, 95],
      songTypes: [
        { name: '流行', value: 35, color: '#409EFF', startDeg: 0 },
        { name: '摇滚', value: 25, color: '#67C23A', startDeg: 126 },
        { name: '民谣', value: 20, color: '#E6A23C', startDeg: 216 },
        { name: '电子', value: 12, color: '#F56C6C', startDeg: 288 },
        { name: '其他', value: 8, color: '#909399', startDeg: 331 }
      ],
      topSingers: [
        { name: '周杰伦', playCount: 1560000, songCount: 156 },
        { name: '林俊杰', playCount: 1250000, songCount: 128 },
        { name: 'Taylor Swift', playCount: 980000, songCount: 98 },
        { name: '薛之谦', playCount: 860000, songCount: 85 },
        { name: '邓紫棋', playCount: 750000, songCount: 72 }
      ],
      topSongs: [
        { name: '晴天', singerName: '周杰伦', playCount: 560000 },
        { name: '修炼爱情', singerName: '林俊杰', playCount: 480000 },
        { name: 'Love Story', singerName: 'Taylor Swift', playCount: 420000 },
        { name: '七里香', singerName: '周杰伦', playCount: 380000 },
        { name: '江南', singerName: '林俊杰', playCount: 350000 }
      ],
      activeUsers: [
        { username: 'user001', nickname: '音乐爱好者', collectCount: 85, commentCount: 128, loginCount: 56, lastLoginTime: '2024-01-15 14:30:25' },
        { username: 'user002', nickname: '摇滚青年', collectCount: 72, commentCount: 96, loginCount: 48, lastLoginTime: '2024-01-15 13:25:18' },
        { username: 'user003', nickname: '流行女王', collectCount: 68, commentCount: 85, loginCount: 42, lastLoginTime: '2024-01-15 12:15:33' },
        { username: 'user004', nickname: '民谣诗人', collectCount: 56, commentCount: 74, loginCount: 38, lastLoginTime: '2024-01-15 11:40:20' },
        { username: 'user005', nickname: '电子先锋', collectCount: 48, commentCount: 62, loginCount: 35, lastLoginTime: '2024-01-15 10:55:45' }
      ]
    }
  },
  created() {
    this.loadStatisticsData()
  },
  methods: {
    loadStatisticsData() {
      // 这里可以调用API获取真实统计数据
      // 目前使用模拟数据展示
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
  width: 60px;
  height: 60px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
}

.stat-icon i {
  font-size: 28px;
  color: white;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
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

.mock-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  height: 200px;
  padding: 20px;
  background-color: #f5f5f5;
  border-radius: 8px;
  margin-bottom: 20px;
}

.chart-bar {
  width: 40px;
  background: linear-gradient(to top, #409EFF, #66b1ff);
  border-radius: 4px 4px 0 0;
  transition: all 0.3s;
}

.chart-bar:hover {
  opacity: 0.8;
}

.chart-labels {
  display: flex;
  justify-content: space-around;
  font-size: 12px;
  color: #999;
}

.pie-chart {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background-color: #f5f5f5;
  margin: 0 auto 20px;
  position: relative;
  overflow: hidden;
}

.pie-segment {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  clip-path: polygon(50% 50%, 50% 0%, 100% 0%, 100% 100%, 0% 100%, 0% 0%, 50% 0%);
}

.pie-legend {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 12px;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  margin-right: 5px;
}
</style>