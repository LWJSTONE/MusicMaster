<template>
  <div class="profile">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="profile-card">
          <div class="avatar-section">
            <el-upload
              class="avatar-uploader"
              action="/api/user/avatar"
              :data="{ userId: userInfo.id }"
              :show-file-list="false"
              :on-success="handleAvatarSuccess"
              :before-upload="beforeAvatarUpload">
              <img :src="userInfo.avatar || defaultAvatar" class="avatar">
              <div class="avatar-overlay">
                <i class="el-icon-camera"></i>
                <span>更换头像</span>
              </div>
            </el-upload>
            <h2>{{ userInfo.nickname || userInfo.username }}</h2>
            <el-tag v-if="isAdmin" type="danger" size="small">管理员</el-tag>
            <el-tag v-else type="success" size="small">普通用户</el-tag>
          </div>
          <div class="user-stats">
            <div class="stat-item">
              <div class="stat-value">{{ stats.songListCount }}</div>
              <div class="stat-label">创建歌单</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ stats.uploadCount }}</div>
              <div class="stat-label">上传歌曲</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ stats.collectCount }}</div>
              <div class="stat-label">收藏歌单</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="16">
        <el-card>
          <el-tabs v-model="activeTab">
            <el-tab-pane label="基本信息" name="basic">
              <el-form :model="profileForm" :rules="profileRules" ref="profileForm" label-width="80px">
                <el-form-item label="用户名">
                  <el-input :value="userInfo.username" disabled></el-input>
                </el-form-item>
                <el-form-item label="昵称" prop="nickname">
                  <el-input v-model="profileForm.nickname" placeholder="请输入昵称"></el-input>
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                  <el-input v-model="profileForm.email" placeholder="请输入邮箱"></el-input>
                </el-form-item>
                <el-form-item label="手机号" prop="phone">
                  <el-input v-model="profileForm.phone" placeholder="请输入手机号"></el-input>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="updateProfile" :loading="saving">保存修改</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <el-tab-pane label="修改密码" name="password">
              <el-form :model="passwordForm" :rules="passwordRules" ref="passwordForm" label-width="100px">
                <el-form-item label="当前密码" prop="oldPassword">
                  <el-input type="password" v-model="passwordForm.oldPassword" placeholder="请输入当前密码" show-password></el-input>
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword">
                  <el-input type="password" v-model="passwordForm.newPassword" placeholder="请输入新密码" show-password></el-input>
                </el-form-item>
                <el-form-item label="确认新密码" prop="confirmPassword">
                  <el-input type="password" v-model="passwordForm.confirmPassword" placeholder="请确认新密码" show-password></el-input>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="updatePassword" :loading="changingPassword">修改密码</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Profile',
  data() {
    const validatePass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请输入密码'))
      } else if (value.length < 6) {
        callback(new Error('密码长度不能少于6位'))
      } else {
        if (this.passwordForm.confirmPassword !== '') {
          this.$refs.passwordForm.validateField('confirmPassword')
        }
        callback()
      }
    }
    const validatePass2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入密码'))
      } else if (value !== this.passwordForm.newPassword) {
        callback(new Error('两次输入密码不一致!'))
      } else {
        callback()
      }
    }

    return {
      userInfo: {},
      activeTab: 'basic',
      saving: false,
      changingPassword: false,
      profileForm: {
        nickname: '',
        email: '',
        phone: ''
      },
      profileRules: {
        nickname: [
          { max: 50, message: '昵称不能超过50个字符', trigger: 'blur' }
        ],
        email: [
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ],
        phone: [
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
        ]
      },
      passwordForm: {
        oldPassword: '',
        newPassword: '',
        confirmPassword: ''
      },
      passwordRules: {
        oldPassword: [
          { required: true, message: '请输入当前密码', trigger: 'blur' }
        ],
        newPassword: [
          { required: true, validator: validatePass, trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, validator: validatePass2, trigger: 'blur' }
        ]
      },
      stats: {
        songListCount: 0,
        uploadCount: 0,
        collectCount: 0
      },
      defaultAvatar: 'https://p1.music.126.net/SUeqj8xv8hJY-_0pAe5mRA==/109951165696893946.jpg'
    }
  },
  computed: {
    isAdmin() {
      return this.userInfo.role === 1
    }
  },
  created() {
    this.loadUserInfo()
    this.loadUserStats()
  },
  methods: {
    loadUserInfo() {
      this.userInfo = JSON.parse(localStorage.getItem('user') || '{}')
      this.profileForm = {
        nickname: this.userInfo.nickname || '',
        email: this.userInfo.email || '',
        phone: this.userInfo.phone || ''
      }
    },

    loadUserStats() {
      const user = JSON.parse(localStorage.getItem('user') || '{}')
      if (!user.id) return

      // 获取创建的歌单数
      axios.get(`/api/song-list/user/${user.id}`).then(res => {
        if (res.data.code === 200) {
          this.stats.songListCount = (res.data.data || []).length
        }
      }).catch(() => {})

      // 获取上传的歌曲数
      axios.get(`/api/song/user/${user.id}`).then(res => {
        if (res.data.code === 200) {
          this.stats.uploadCount = (res.data.data || []).length
        }
      }).catch(() => {})

      // 获取收藏数
      axios.get('/api/collect/page', {
        params: { current: 1, size: 1, userId: user.id }
      }).then(res => {
        if (res.data.code === 200) {
          this.stats.collectCount = res.data.data.total || 0
        }
      }).catch(() => {})
    },

    updateProfile() {
      this.$refs.profileForm.validate(valid => {
        if (valid) {
          this.saving = true
          const user = JSON.parse(localStorage.getItem('user') || '{}')
          
          axios.put('/api/user/profile', {
            id: user.id,
            ...this.profileForm
          }).then(res => {
            this.saving = false
            if (res.data.code === 200) {
              this.$message.success('保存成功')
              // 更新本地存储的用户信息
              const updatedUser = { ...this.userInfo, ...this.profileForm }
              localStorage.setItem('user', JSON.stringify(updatedUser))
              this.userInfo = updatedUser
            } else {
              this.$message.error(res.data.message)
            }
          }).catch(err => {
            this.saving = false
            this.$message.error('保存失败')
            console.error(err)
          })
        }
      })
    },

    updatePassword() {
      this.$refs.passwordForm.validate(valid => {
        if (valid) {
          const user = JSON.parse(localStorage.getItem('user') || '{}')
          this.changingPassword = true

          axios.put('/api/user/password', null, {
            params: {
              userId: user.id,
              oldPassword: this.passwordForm.oldPassword,
              newPassword: this.passwordForm.newPassword
            }
          }).then(res => {
            this.changingPassword = false
            if (res.data.code === 200) {
              this.$message.success('密码修改成功')
              this.passwordForm = {
                oldPassword: '',
                newPassword: '',
                confirmPassword: ''
              }
            } else {
              this.$message.error(res.data.message)
            }
          }).catch(err => {
            this.changingPassword = false
            this.$message.error('密码修改失败')
            console.error(err)
          })
        }
      })
    },

    beforeAvatarUpload(file) {
      const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)
      const isLt5M = file.size / 1024 / 1024 < 5

      if (!isImage) {
        this.$message.error('只能上传图片文件!')
        return false
      }
      if (!isLt5M) {
        this.$message.error('图片大小不能超过 5MB!')
        return false
      }
      return true
    },

    handleAvatarSuccess(res) {
      if (res.code === 200) {
        this.$message.success('头像更换成功')
        // 更新本地存储的用户信息
        const updatedUser = { ...this.userInfo, avatar: res.data.url }
        localStorage.setItem('user', JSON.stringify(updatedUser))
        this.userInfo = updatedUser
      } else {
        this.$message.error(res.message || '上传失败')
      }
    }
  }
}
</script>

<style scoped>
.profile {
  padding: 20px;
}

.profile-card {
  text-align: center;
}

.avatar-section {
  padding: 30px 0;
}

.avatar-uploader {
  display: inline-block;
  margin-bottom: 20px;
}

.avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  cursor: pointer;
  position: relative;
}

.avatar-uploader {
  position: relative;
}

.avatar-overlay {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
  cursor: pointer;
  top: 0;
}

.avatar-uploader:hover .avatar-overlay {
  opacity: 1;
}

.avatar-overlay i {
  font-size: 24px;
  color: #fff;
  margin-bottom: 5px;
}

.avatar-overlay span {
  color: #fff;
  font-size: 12px;
}

.avatar-section h2 {
  margin: 15px 0 10px;
  font-size: 20px;
  color: #333;
}

.user-stats {
  display: flex;
  justify-content: space-around;
  padding: 20px 0;
  border-top: 1px solid #e8e8e8;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
}

.stat-label {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}
</style>
