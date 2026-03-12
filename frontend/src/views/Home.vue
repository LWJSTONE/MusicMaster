<template>
  <div class="home-container">
    <el-container>
      <el-aside width="200px" class="sidebar">
        <div class="logo">MusicMaster</div>
        <el-menu
          :default-active="$route.path"
          class="menu"
          router
          background-color="#001529"
          text-color="#fff"
          active-text-color="#1890ff">
          <el-menu-item index="/player">
            <i class="el-icon-headset"></i>
            <span>音乐播放</span>
          </el-menu-item>

          <el-menu-item index="/collect">
            <i class="el-icon-star-off"></i>
            <span>我的收藏</span>
          </el-menu-item>

          <el-menu-item index="/my-comments">
            <i class="el-icon-chat-dot-round"></i>
            <span>我的评论</span>
          </el-menu-item>

          <el-submenu index="admin" v-if="isAdmin">
            <template slot="title">
              <i class="el-icon-s-tools"></i>
              <span>系统管理</span>
            </template>
            <el-menu-item index="/user">用户管理</el-menu-item>
            <el-menu-item index="/singer">歌手管理</el-menu-item>
            <el-menu-item index="/song">歌曲管理</el-menu-item>
            <el-menu-item index="/song-list">歌单管理</el-menu-item>
            <el-menu-item index="/comment">评论管理</el-menu-item>
            <el-menu-item index="/statistics">数据统计</el-menu-item>
          </el-submenu>
        </el-menu>
      </el-aside>

      <el-container>
        <el-header class="header">
          <div class="header-content">
            <h2>{{ pageTitle }}</h2>
            <div class="user-info">
              <span>{{ userInfo.nickname || userInfo.username }}</span>
              <el-tag v-if="isAdmin" type="danger" size="mini" style="margin-left: 8px;">管理员</el-tag>
              <el-tag v-else type="success" size="mini" style="margin-left: 8px;">普通用户</el-tag>
              <el-button type="text" @click="logout" style="margin-left: 10px;">退出</el-button>
            </div>
          </div>
        </el-header>

        <el-main class="main">
          <router-view></router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      userInfo: {}
    }
  },
  computed: {
    isAdmin() {
      return this.userInfo.role === 1
    },
    pageTitle() {
      return this.$route.meta.title || '音乐播放'
    }
  },
  created() {
    this.userInfo = JSON.parse(localStorage.getItem('user') || '{}')
  },
  methods: {
    logout() {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      this.$router.push('/login')
      this.$message.success('退出成功')
    }
  }
}
</script>

<style scoped>
.home-container {
  width: 100%;
  height: 100vh;
}

.el-container {
  height: 100%;
}

.sidebar {
  background-color: #001529;
}

.logo {
  height: 64px;
  line-height: 64px;
  text-align: center;
  color: #fff;
  font-size: 20px;
  font-weight: bold;
  background-color: #002140;
}

.menu {
  border-right: none;
}

.header {
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  padding: 0;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 20px;
}

.header-content h2 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.user-info {
  display: flex;
  align-items: center;
}

.main {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
