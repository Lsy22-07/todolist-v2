<template>
    <div class="myCategory">
        <div class="category">我的分类</div>
        <div class="button">
            <el-button @click="submit">新建</el-button>
        </div>
        <div v-for="value in 20 " :key="value" class="categoryList" >数字{{ value }}</div>
    </div>
</template>

<script setup>

</script>

<style lang="scss" scoped>
   .categoryList{
    height: 50px;
    width: 100px;
    background-color: #fb0606;
    margin: 10px;
   }
</style>