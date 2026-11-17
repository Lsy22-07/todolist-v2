<template>
    <div class="login">
        <div class="loginMenue">
            <div class="loginName">
               <img src="../img/logo-32.png" class="loginImg">
               芯动力dolist
            </div>
            <div class="loginGuide">
               <el-tabs v-model="active"  class="loginCard" @click="change">
                   <el-tab-pane  label="登录" name="one"></el-tab-pane>
                   <el-tab-pane  label="注册" name="two" ></el-tab-pane>
               </el-tabs>
            </div>
            <div class="loginInfo" v-if="Login">
                <el-form  label-position="right" label-width="100px" size="large">
                   <el-form-item label="用户名">
                     <el-input v-model="userName" placeholder="请输入用户名" style="width: 350px;" class="loginUsername" :prefix-icon="UserFilled"></el-input>
                   </el-form-item>
                   <el-form-item label="密码">
                     <el-input v-model="passWord" placeholder="请输入密码" style="width: 350px;" class="loginPassword" :prefix-icon="GoodsFilled" show-password="true" clearable></el-input>
                    </el-form-item>
                    <el-button @click="submit" class="loginButton" type="primary" :plain="true">登录</el-button>
                </el-form>
            </div>
            <register v-if="!Login" @change="Login=true ,active='one'"></register>
        </div>
    </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import{GoodsFilled, UserFilled} from '@element-plus/icons-vue'
import register from './Register.vue';
import { login } from '@/axios/axios.js';
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';
const router=useRouter()
const active=ref('one')
const userName=ref('')
const passWord=ref('')
const Login=ref(true)
const state=reactive({
   username:'',
   password:''
})
state.username=userName.value
state.password=passWord.value
const change=()=>{
    Login.value=active.value=='one'?true:false
    
}
const submit=async()=>{
    const {code,data}= await login(state)
    if(code==2004){
        ElMessage({
            message:'用户名或密码错误',
            type:'error',
            showClose:true,
            plain:true
        })
    }else if(code==2003){
        ElMessage({
            message:'登录过于频繁,请1分钟后尝试',
            type:'error',
            showClose:true,
            plain:true
        })
    }else{
        ElMessage({
            message:'登录成功',
            type:'success',
            showClose:true,
            plain:true
        })
        localStorage.setItem('token',data.token)
        const expireTime=new Date().getTime()+data.expiresIn*1000
        localStorage.setItem('tokeneExpire',expireTime)
        router.push('/Home')
    }
}
</script>

<style lang="scss" scoped>
    .login{
        position: fixed;
        width: 100%;
        height: 100%;
        background-color: #d9d2d2;
      .loginMenue{
        position: fixed;
        top: 25%;
        left: 35%;
        height: 500px;
        width: 500px;
        border: 0 solid #0e0e0e;
        background-color: #fff;
        display: flex;
        flex-direction: column;
        justify-content: center;
        box-shadow: 0 15px 35px rgba(64, 158, 255, 0.4);
        
        .loginName{
           position: relative;
           font-size:xx-large;
           top: -10%;
           left: 35%;
           .loginImg{
            position: absolute;
            top: 20%;
            left: -7%;
           }
        }
        .loginUsername :deep(.el-input__wrapper) {
            border-radius: 999px;
            padding:0 20px ;
        
        }
        .loginPassword :deep(.el-input__wrapper){
            border-radius: 999px;
            padding:0 20px;
           
            
        }
        .loginCard :deep(.el-tabs__nav){
              display: flex;
              width: 100%;
        }
        .loginCard :deep(.el-tabs__item){
            flex: 1;
            text-align: center;
            padding: 0 20px;
            font-size: larger;
        }
        .loginButton{
            position: absolute;
            left: 19%;
            border-radius: 999px;
            padding: 0 20px;
            width: 300px;
            height: 50px;
            margin: 10px;
        }
        .registerButton{
            position: absolute;
            left: 22%;
            border-radius: 999px;
            padding:0 20px;
            width: 300px;
            height: 43px;
           
        }
      }
    }
</style>