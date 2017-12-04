//Class to parse the dates 
// Includes a method to compare which date is bigger

class Date {
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
  String date;
  String time;
  String date_time;
  float dateTimeAsFloat;
  
  Date(){
    year = month = day = hour = minute = second = 0;
    date = time = date_time = "";
    dateTimeAsFloat=MIN_FLOAT;
  }
  
  Date(String date){
    date_time=date;
    String[] s = date.split(" ");
    
    date=s[0];
    String[] cal = s[0].split("-");
    year = parseInt(cal[0]);
    month=parseInt(cal[1]);
    day=parseInt(cal[2]);
    
    time=s[1];
    String[] t = s[1].split(":");
    hour=parseInt(t[0]);
    minute=parseInt(t[1]);
    second=parseInt(t[2]);
    
    //Use day/hour/minute/second for the x axis only to get good enough resolution.
    //String smashed=cal[0]+cal[1]+cal[2]+t[0]+t[1]+t[2];
    String smashed=cal[2]+t[0]+t[1]+t[2];
    dateTimeAsFloat=buildDateTimeAsFloat(smashed);
  }
  
  String getDateTime(){
    return date_time;
  }
  
  String getDate(){
    String[] s = date_time.split(" ");
    return s[0];
  }
  
  String getTime(){
    return time;
  }
  
  int getYear(){
    return year;
  }
  
  int getMonth(){
    return month;
  }
  
  int getDay(){
    return day;
  }
  
  int getHour(){
    return hour;
  }
  
  int getMinute(){
    return minute;
  }
  
  int getSecond(){
    return second;
  }
  
  float getDateTimeAsFloat(){
    return dateTimeAsFloat;
  }
  
  //  float buildDateTimeAsFloat(){
  //  float ans = 0;
  //  ans+=year/1000;
  //  ans +=month/100;
  //  ans+=day/1000;
  //  ans+=hour/;
  //  ans+=minute;
  //  ans+=second;
  //  return ans;
  //}
  
  float buildDateTimeAsFloat(String smashed){
    float ans = parseFloat(smashed);
    return ans;
  }
  
  boolean isBiggerThan(Date d){
    //The order of this if statement is extremely important.
    if(this.year > d.year){
      return true;
    } else if (this.year < d.year){
      return false;
    } else if (this.month > d.month){
      return true;
    } else if (this.month < d.month){
      return false;
    } else if(this.day > d.day){
      return true;
    } else if(this.day < d.day){
      return false;
    } else if(this.hour > d.hour){
      return true;
    } else if(this.hour < d.hour){
      return false;
    } else if(this.minute > d.minute){
      return true;
    } else if (this.minute < d.minute){
      return false;
    } else if (this.second > d.second){
      return true;
    } else if(this.second < d.second) {
      return false;
    } else { //They are the same date to the second
      return false;
    }
  }
}