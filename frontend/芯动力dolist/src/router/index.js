import { createRouter, createWebHistory } from 'vue-router'
import { isTokenExpired } from '@/utils/auth'
import { ElMessage } from 'element-plus'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path:'/',
      name:'Login',
      component:()=>import('../views/Login.vue')
    },
    {
      path:'/Home',
      name:'Home',
      component:()=>import('../views/Home.vue')
    }
  ],
})
router.beforeEach((to,from,next)=>{
  if(to.meta.requiresAuth&&isTokenExpired()){
    ElMessage.warning('登录已过期，请重新登录')
    next('/Login')
  }else{
    next()
  }
})
export default router
