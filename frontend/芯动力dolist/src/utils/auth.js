export function isTokenExpired(){
    const token =localStorage.getItem('token')
    const expireTime=localStorage.getItem('tokenExpire')
    if(!token||!expireTime) return true
    const date= Date.now()
    if(date>Number(expireTime)){
        localStorage.removeItem('token')
        localStorage.removeItem('tokenExpire')
        return true
    }
    return false
}