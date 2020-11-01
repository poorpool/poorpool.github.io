---
title: JDBC 学习札记
date: 2020-06-02 11:09:34
tags:
- Java
- 数据库
categories:
- 编程语言
---
课程[来源](https://www.bilibili.com/video/BV1eJ411c7rf?from=search&seid=1514951991050910155)

<!--more-->

# 编写JDBC程序的流程

![images](/images/javaknows/3.png)

# 获取数据连接

厂商实现java.sql.Driver接口。对于mysql，是com.mysql.cj.jdbc.Driver实现了它。

## 各种连接方式
递进地看看怎么写

1-显式出现了api。
```java
import com.mysql.cj.jdbc.Driver;//就是这里居然把api硬写到代码里了
...省略函数体
Driver driver = new Driver();
String url = "jdbc:mysql://localhost:3306/test";
Properties info = new Properties();
info.setProperty("user", "root");
info.setProperty("password", "你的密码");
Connection conn = driver.connect(url, info);
System.out.println(conn);
conn.close();
```

2-反射
```java
import java.sql.Driver;
...
Driver driver = (Driver)Class.forName("com.mysql.cj.jdbc.Driver").getConstructor().newInstance();
```

注意java.sql.Driver是一个接口。这样用反射实现，可以把这个字符串丢到文件里头去。

3-DriverManager
```java
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConnectionTest {
    @Test
    public void testConnection1 () {
        try {
            //数据库连接四要素
            String url = "jdbc:mysql://localhost:3306/test";
            String user = "root";
            String password = "153246";
            String driver = "com.mysql.cj.jdbc.Driver";

            Class.forName(driver);
            
            /*
            com.mysql.cj.jdbc.Driver已经注册了DriverManager，下面是源码
            public class Driver extends NonRegisteringDriver implements java.sql.Driver {
                public Driver() throws SQLException {
                }
            
                static {
                    try {
                        DriverManager.registerDriver(new Driver());
                    } catch (SQLException var1) {
                        throw new RuntimeException("Can't register driver!");
                    }
                }
            }
            */
            

            Connection conn = DriverManager.getConnection(url, user, password);
            System.out.println(conn);
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

5-扔到配置文件里头。这个是坠吼的。

直接在src里头写jdbc.properties
```
url=jdbc:mysql://localhost:3306/test"
user=root
password=你的密码
driverClass=com.mysql.cj.jdbc.Driver
```

```java
InputStream is = ConnectionTest.class.getClassLoader().getResourceAsStream("jdbc.properties");
Properties properties = new Properties();
properties.load(is);
properties.getProperty("user");
...
```

# 操作和访问数据库

# 使用普通的Statement
```
Statement st = connection.createStatement();
int result = st.excuteUpdate(String sql):执行更新操作INSERT、UPDATE、DELETE
ResultSet rs = st.executeQuery(String sql):执行查询操作SELECT
```

敢这么写的不仅要拼串还要被sql注入打爆。

# PreparedStatement

可以通过调用 Connection 对象的 preparedStatement(String sql) 方法获取 PreparedStatement 对象。能提高性能，防sql注入。

不写了，直接调Druid连接池和dbutils吧（狗头