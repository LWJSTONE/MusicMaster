import Vue from 'vue'
import VueRouter from 'vue-router'
import Login from '@/views/Login.vue'
import Home from '@/views/Home.vue'
import UserManagement from '@/views/UserManagement.vue'
import SingerManagement from '@/views/SingerManagement.vue'
import SongManagement from '@/views/SongManagement.vue'
import SongListManagement from '@/views/SongListManagement.vue'
import CommentManagement from '@/views/CommentManagement.vue'
import CollectManagement from '@/views/CollectManagement.vue'
import Statistics from '@/views/Statistics.vue'
import Player from '@/views/Player.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/home',
    name: 'Home',
    component: Home,
    redirect: '/player',
    children: [
      {
        path: '/player',
        name: 'Player',
        component: Player,
        meta: { title: '音乐播放' }
      },
      {
        path: '/user',
        name: 'UserManagement',
        component: UserManagement,
        meta: { title: '用户管理', requiresAdmin: true }
      },
      {
        path: '/singer',
        name: 'SingerManagement',
        component: SingerManagement,
        meta: { title: '歌手管理', requiresAdmin: true }
      },
      {
        path: '/song',
        name: 'SongManagement',
        component: SongManagement,
        meta: { title: '歌曲管理', requiresAdmin: true }
      },
      {
        path: '/song-list',
        name: 'SongListManagement',
        component: SongListManagement,
        meta: { title: '歌单管理', requiresAdmin: true }
      },
      {
        path: '/comment',
        name: 'CommentManagement',
        component: CommentManagement,
        meta: { title: '评论管理', requiresAdmin: true }
      },
      {
        path: '/collect',
        name: 'CollectManagement',
        component: CollectManagement,
        meta: { title: '收藏管理' }
      },
      {
        path: '/statistics',
        name: 'Statistics',
        component: Statistics,
        meta: { title: '数据统计', requiresAdmin: true }
      }
    ]
  }
]

const router = new VueRouter({
  mode: 'hash',
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')

  if (to.path !== '/login' && !token) {
    next('/login')
  } else if (to.meta.requiresAdmin) {
    const user = JSON.parse(localStorage.getItem('user') || '{}')
    if (user.role !== 1) {
      next('/player')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router