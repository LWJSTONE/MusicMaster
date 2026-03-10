<template>
  <div class="user-management">
    <el-card>
      <div slot="header" class="card-header">
        <span>用户管理</span>
        <el-button type="primary" size="small" @click="showAddDialog">添加用户</el-button>
      </div>

      <!-- 搜索区域 -->
      <div class="search-area">
        <el-input
          v-model="searchForm.username"
          placeholder="搜索用户名"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="loadUserList"
          @keyup.enter.native="searchUser">
        </el-input>
        <el-button type="primary" icon="el-icon-search" @click="searchUser">搜索</el-button>
      </div>

      <!-- 用户表格 -->
      <el-table
        :data="userList"
        border
        stripe
        style="width: 100%; margin-top: 20px;">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="username" label="用户名" width="150"></el-table-column>
        <el-table-column prop="nickname" label="昵称" width="150"></el-table-column>
        <el-table-column prop="email" label="邮箱" width="200"></el-table-column>
        <el-table-column prop="phone" label="手机号" width="120"></el-table-column>
        <el-table-column prop="role" label="角色" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.role === 1 ? 'danger' : 'primary'">
              {{ scope.row.role === 1 ? '管理员' : '普通用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button size="mini" @click="editUser(scope.row)">编辑</el-button>
            <el-button size="mini" :type="scope.row.status === 1 ? 'warning' : 'success'" @click="toggleStatus(scope.row)">
              {{ scope.row.status === 1 ? '禁用' : '启用' }}
            </el-button>
            <el-button size="mini" type="danger" @click="deleteUser(scope.row)">删除</el-button>
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

    <!-- 添加/编辑用户对话框 -->
    <el-dialog :title="dialogTitle" :visible.sync="showDialog" width="500px">
      <el-form :model="userForm" :rules="rules" ref="userForm" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="isEdit"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input type="password" v-model="userForm.password"></el-input>
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="userForm.nickname"></el-input>
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email"></el-input>
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userForm.phone"></el-input>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="userForm.role" placeholder="请选择角色">
            <el-option label="普通用户" :value="0"></el-option>
            <el-option label="管理员" :value="1"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="saveUser">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'UserManagement',
  data() {
    return {
      userList: [],
      searchForm: {
        username: ''
      },
      pagination: {
        current: 1,
        size: 10,
        total: 0
      },
      showDialog: false,
      isEdit: false,
      dialogTitle: '添加用户',
      userForm: {
        id: null,
        username: '',
        password: '',
        nickname: '',
        email: '',
        phone: '',
        role: 0
      },
      rules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
        ],
        nickname: [
          { required: true, message: '请输入昵称', trigger: 'blur' }
        ],
        email: [
          { required: true, message: '请输入邮箱', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
        ]
      }
    }
  },
  created() {
    this.loadUserList()
  },
  methods: {
    loadUserList() {
      axios.get('/api/user/page', {
        params: {
          current: this.pagination.current,
          size: this.pagination.size,
          username: this.searchForm.username || undefined
        }
      }).then(res => {
        if (res.data.code === 200) {
          const data = res.data.data
          this.userList = data.records
          this.pagination.total = data.total
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('加载用户列表失败')
        console.error(err)
      })
    },

    searchUser() {
      this.pagination.current = 1
      this.loadUserList()
    },

    showAddDialog() {
      this.isEdit = false
      this.dialogTitle = '添加用户'
      this.userForm = {
        id: null,
        username: '',
        password: '',
        nickname: '',
        email: '',
        phone: '',
        role: 0
      }
      this.showDialog = true
    },

    editUser(user) {
      this.isEdit = true
      this.dialogTitle = '编辑用户'
      this.userForm = {
        id: user.id,
        username: user.username,
        nickname: user.nickname,
        email: user.email,
        phone: user.phone,
        role: user.role
      }
      this.showDialog = true
    },

    saveUser() {
      this.$refs.userForm.validate(valid => {
        if (valid) {
          const url = this.isEdit ? '/api/user' : '/api/user/register'
          const method = this.isEdit ? 'put' : 'post'

          axios({
            method: method,
            url: url,
            data: this.userForm
          }).then(res => {
            if (res.data.code === 200) {
              this.$message.success(this.isEdit ? '更新成功' : '添加成功')
              this.showDialog = false
              this.loadUserList()
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

    toggleStatus(user) {
      const newStatus = user.status === 1 ? 0 : 1
      axios.put('/api/user/status', null, {
        params: {
          userId: user.id,
          status: newStatus
        }
      }).then(res => {
        if (res.data.code === 200) {
          this.$message.success('状态更新成功')
          this.loadUserList()
        } else {
          this.$message.error(res.data.message)
        }
      }).catch(err => {
        this.$message.error('状态更新失败')
        console.error(err)
      })
    },

    deleteUser(user) {
      this.$confirm('确定要删除该用户吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        axios.delete(`/api/user/${user.id}`).then(res => {
          if (res.data.code === 200) {
            this.$message.success('删除成功')
            this.loadUserList()
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
      this.loadUserList()
    },

    handleCurrentChange(val) {
      this.pagination.current = val
      this.loadUserList()
    }
  }
}
</script>

<style scoped>
.user-management {
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