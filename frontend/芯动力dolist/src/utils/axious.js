import  axios from 'axios'
const ajax=axios.create({
    baseURL:'http://localhost:8080',
    timeout:10000,
    headers:{
        'Content-Type':'application/json;charset=UTF-8'
    }
})
ajax.interceptors.request.use(
    (config)=>{
       const token=localStorage.getItem('token')
       if(token){
        config.headers.Authorization=`Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.${token}`
       }
       return config
    },
    (error)=>{
        return Promise.reject(error)
    }
)
ajax.interceptors.response.use(
    (response)=>{
        return response.data
    },
    (error)=>{
        return Promise.reject(error)
    }
)
export default ajax