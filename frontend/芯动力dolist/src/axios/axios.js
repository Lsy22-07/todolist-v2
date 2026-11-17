import ajax from "@/utils/axious"
export function Register(param){
    return ajax.post('/api/auth/register',param)
}
export function login(param){
    return ajax.post('/api/auth/login',param)
}