<template>
    <div>
        <el-form label-position="right" label-width="100px" size="large" >
            <el-form-item label="用户名" props="registUsername" :rules="[{required:true,message:'请输入用户名'}]">
                <el-input v-model="state.username" placeholder="请输入用户名" :prefix-icon="Avatar" style="width: 350px;" class="registerUsername"></el-input>
            </el-form-item>
            <el-form-item label="昵称" props="registerName" :rules="[{required:true,message:'请输入昵称'},{validator:judge,trigger:'change'}]">
                <el-input v-model="state.nickname" placeholder="请输入昵称" :prefix-icon="Avatar" style="width: 350px;" class="registerName" ></el-input>
            </el-form-item>
            <el-form-item label="密码" props="registerPassword" :rules="[{ required: true ,message:'请输入密码' }]">
                <el-input v-model="state.password" placeholder="请输入密码" :prefix-icon="GoodsFilled" show-password="true" clearable style="width: 350px;" class="registerPassword"></el-input>
            </el-form-item>
            <el-button @click="register(state)" type="primary" class="registerButton" :plain="true">注册</el-button>
        </el-form>
    </div>
</template>

<script setup>
import {Avatar,GoodsFilled} from '@element-plus/icons-vue'
import { reactive, ref } from 'vue'
import { Register } from '@/axios/axios'
import {ElMessage} from 'element-plus'
const emit=defineEmits(['change'])
const state=reactive({
    username:'',
    password:'',
    nickname:''
})
const judge=(rule,value)=>{
    if(value.length>50){
        throw new Error('最多50位')
    }
}
const register=async(registerInfo)=>{
   try{
        await registerInfo.value.validate()
   }catch(error){
        registerInfo.value?.clearValidate('nickname')
   }
     const code=await Register(state).code
      if(code==1001){
        ElMessage({
            message:'用户名长度在3-20之间，密码长度在6-20之间',
            type:'error',
            showClose:true,
            plain:true
        })
      }else if(code==3001){
       ElMessage({
            message:'用户名已存在',
            type:'error',
            showClose:true,
            plain:true
        })
      }else{
       ElMessage({
        message:'注册成功',
        type:'success',
        showClose:true,
        plain:true
       })
       emit('change')
      }
}
</script>

<style lang="scss" scoped>
       .registerUsername :deep(.el-input__wrapper){
          border-radius: 999px;
          padding: 0 20px;
       }
       .registerName :deep(.el-input__wrapper) {
            border-radius: 999px;
            padding:0 20px ;
        }
        .registerPassword :deep(.el-input__wrapper){
            border-radius: 999px;
            padding:0 20px;
        }
        .registerButton{
            position: absolute;
            left: 22%;
            border-radius: 999px;
            padding:0 20px;
            width: 300px;
            height: 43px;
        }
</style>