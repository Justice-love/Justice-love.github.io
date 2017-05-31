---
layout: post
title:  "MyBatis ResultMap"
date:   2017-05-31
excerpt: "一个select节点配置多个resultMap"
tag:
- mybatis
- resultMap
comments: true
---
## mybatis多resultMap使用场景

一条SQL返回多个ResultSet，多见于调用存储过程，用于每个resultSet的关系映射。

## 写法
``` xml
<!-- resultMaps -->
<resultMap id="user" type="com.eddy.model.User">
    <result column="id" property="id"/>
    <result column="active" property="active"/>
    <result column="login_name" property="loginName"/>
    <result column="create_time" property="createTime"/>
    <result column="update_time" property="updateTime"/>
    <association property="company" column="company_id"  select="com.oceanwing.dao.mapper.CompanyMapper.selectById"/>
    <collection property="businessEntities" column="id" select="com.oceanwing.dao.mapper.BusinessEntityMapper.selectByUserId"/>
</resultMap>

<resultMap id="param" type="integer">
    <constructor>
        <arg column="param" javaType="int"/>
    </constructor>
</resultMap>

<resultMap id="userRole" type="com.eddy.model.Role">
    <result column="id" property="id"/>
    <result column="name" property="name"/>
    <result column="title" property="title"/>
    <result column="create_time" property="createTime"/>
    <result column="update_time" property="updateTime"/>
    <association property="company" column="company_id"  select="com.oceanwing.dao.mapper.CompanyMapper.selectById"/>
</resultMap>

<!-- select -->
<select id="mutiResult" resultMap="param, user, userRole" statementType="CALLABLE" >
    call muti_result(#{param})
</select>
```

## 存储过程
``` sql
DELIMITER //
create PROCEDURE muti_result(in param int)
begin
	select param;
	select * from user where id = 1;
	select * from role where id = 1;
end //
DELIMITER ;
```

## 结果
``` java
@Test
public void test10() {
    List<ArrayList> result = userMapper.mutiResult(2);
    System.out.println(result);
}
//[[2], [User], [Role]]

```

## 补充
判断是否有多个结果集并获取下一个结果集。
``` java
/**
 * Moves to this <code>Statement</code> object's next result, returns
 * <code>true</code> if it is a <code>ResultSet</code> object, and
 * implicitly closes any current <code>ResultSet</code>
 * object(s) obtained with the method <code>getResultSet</code>.
 *
 * <P>There are no more results when the following is true:
 * <PRE>{@code
 *     // stmt is a Statement object
 *     ((stmt.getMoreResults() == false) && (stmt.getUpdateCount() == -1))
 * }</PRE>
 *
 * @return <code>true</code> if the next result is a <code>ResultSet</code>
 *         object; <code>false</code> if it is an update count or there are
 *         no more results
 * @exception SQLException if a database access error occurs or
 * this method is called on a closed <code>Statement</code>
 * @see #execute
 */
boolean getMoreResults() throws SQLException;

/**
 *  Retrieves the current result as a <code>ResultSet</code> object.
 *  This method should be called only once per result.
 *
 * @return the current result as a <code>ResultSet</code> object or
 * <code>null</code> if the result is an update count or there are no more results
 * @exception SQLException if a database access error occurs or
 * this method is called on a closed <code>Statement</code>
 * @see #execute
 */
ResultSet getResultSet() throws SQLException;
```