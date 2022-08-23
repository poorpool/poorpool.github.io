---
title: SSM 框架学习笔记 5
date: 2020-07-02 23:13:14
tags:
- Java
- Spring
categories:
- 框架
---
[课程来源](https://www.bilibili.com/video/BV1d4411g7tv)

<!--more-->

# MyBatis

## 动态 sql

~~超级拼串王。~~

if 标签：比如说根据 bean 查询，不是 null 的就要作为条件去查：

```java
public class Teacher {
    private Integer id;
    private String teacherName;
    private String course;
    private String address;
    private Date birth;
    //...
}
```

```java
public interface TeacherDao {
    public Teacher getTeacherById(Integer id);

    /**
     * 按照 teacher 中不是 null 的东西查询
     * @param teacher
     * @return
     */
    public List<Teacher> getTeacherByCondition(Teacher teacher);
}
```

```xml
<select id="getTeacherByCondition" resultType="net.yxchen.bean.Teacher">
    select * from t_teacher
        <trim prefix="where" prefixOverrides="" suffix="" suffixOverrides="and">
            <!-- 添加 where 前缀，取消 and 后缀（如果有的话） -->
            <if test="id!=null"><!-- OGNL 表达式 -->
                id > #{id} and
            </if>
            <if test="birth!=null">
                #{birth} > birth_date
            </if>
        </trim>
</select>
```

嫌上面的麻烦，可以把 trim 换成 where 标签然后把 and 写在前头而不是后头，也可以。

foreach：

```xml
<foreach collection="ids" item="idItem" separator="," open="(" close=")">
    #{idItem}
</foreach>
```

ids 是一个 `@Param("ids") List<Integer> ids`。

还有 choose 标签，就相当于 switch。

还有 set 标签，用于 update。update 里头一堆 if 后头带个逗号，可以用 set 标签包裹起来，就能消掉逗号，像 where 一样。

## 缓存

一级缓存：sqlSession 级别，默认存在。任何一次增删改都会清空一级缓存。

## MBG

mybatis generator，根据数据库表就能自动生成 bean、dao，非常方便。