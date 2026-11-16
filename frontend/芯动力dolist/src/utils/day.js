import dayjs from "dayjs"
export function timeTrsnslate(time,format='yyyy-MM-dd HH:mm'){
    if(!time){
        return '-'
    }
    return dayjs(time).utcOffset(8).format(format)
}